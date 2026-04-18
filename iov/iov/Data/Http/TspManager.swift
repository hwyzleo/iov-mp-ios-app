//
//  BaseAPI.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation
import Alamofire
import UIKit

// TSP 请求头
var tspHeaders: HTTPHeaders {
    let token = UserManager.getToken()
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

    var headers: HTTPHeaders = [
        "X-Device-Id": getDeviceId(),
        "X-Platform": "ios",
        "X-Os-Version": UIDevice.current.systemVersion,
        "X-App-Version": appVersion,
        "X-Client-Id": "iphone-capp",
        "X-Client-Type": "MOBILE"
    ]

    if !token.isEmpty {
        headers["Authorization"] = "Bearer \(token)"
    }

    return headers
}

/// TSP 管理
class TspManager {
    
    // 刷新锁，防止并发刷新
    private static var isRefreshing = false
    private static var refreshCompletionHandlers: [(String) -> Void] = []
    
    // POST 请求
    static func requestPost<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        ensureTokenValid { result in
            switch result {
            case .success:
                performRequestPost(path: path, parameters: parameters, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    static func requestGet<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        ensureTokenValid { result in
            switch result {
            case .success:
                performRequestGet(path: path, parameters: parameters, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    static func requestPut<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        ensureTokenValid { result in
            switch result {
            case .success:
                performRequestPut(path: path, parameters: parameters, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // 确保 token 有效
    private static func ensureTokenValid(completion: @escaping (Result<Void, Error>) -> Void) {
        if !UserManager.isLogin() {
            completion(.success(()))
            return
        }
        
        if UserManager.isTokenExpiringSoon(threshold: 300) {
            performTokenRefresh { result in
                completion(result)
            }
        } else {
            completion(.success(()))
        }
    }
    
    // 执行 token 刷新
    private static func performTokenRefresh(completion: @escaping (Result<Void, Error>) -> Void) {
        if isRefreshing {
            refreshCompletionHandlers.append { newToken in
                if newToken.isEmpty {
                    completion(.failure(NSError(domain: "TokenRefreshError", code: -1, userInfo: [NSLocalizedDescriptionKey: "刷新 token 失败"])))
                } else {
                    completion(.success(()))
                }
            }
            return
        }
        
        isRefreshing = true
        
        let refreshToken = UserManager.getRefreshToken()
        if refreshToken.isEmpty {
            isRefreshing = false
            completion(.failure(NSError(domain: "TokenRefreshError", code: -1, userInfo: [NSLocalizedDescriptionKey: "refreshToken 不存在"])))
            return
        }
        
        print("access_token 即将过期，开始刷新...")
        
        TspApi.refreshToken(refreshToken: refreshToken) { result in
            isRefreshing = false
            let handlers = refreshCompletionHandlers
            refreshCompletionHandlers.removeAll()
            
            switch result {
            case let .success(response):
                if response.isSuccess, let data = response.data {
                    let newExpiresAt = Date(timeIntervalSince1970: Double(data.tokenExpires ?? 0) / 1000.0)
                    UserManager.updateTokens(
                        token: data.token ?? "",
                        refreshToken: data.refreshToken ?? refreshToken,
                        expiresAt: newExpiresAt
                    )
                    print("access_token 刷新成功")
                    
                    for handler in handlers {
                        handler(data.token ?? "")
                    }
                    completion(.success(()))
                } else {
                    print("access_token 刷新失败：\(response.message ?? "")")
                    for handler in handlers {
                        handler("")
                    }
                    completion(.failure(NSError(domain: "TokenRefreshError", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message ?? "刷新失败"])))
                }
            case let .failure(error):
                print("access_token 刷新请求失败：\(error)")
                for handler in handlers {
                    handler("")
                }
                completion(.failure(error))
            }
        }
    }
    
    // 实际执行 POST 请求
    private static func performRequestPost<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        print("request post tsp:", path, parameters, tspHeaders)
        NetworkManager.shared.requestPost(path: AppGlobalState.shared.tspUrl + path, parameters: parameters, headers: tspHeaders) { result in
            switch result {
            case let .success(data):
                let parseResult: Result<T, Error> = parseData(data)
                completion(parseResult)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // 实际执行 GET 请求
    private static func performRequestGet<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        print("request get tsp:", path, parameters, tspHeaders)
        NetworkManager.shared.requestGet(path: AppGlobalState.shared.tspUrl + path, parameters: parameters, headers: tspHeaders) { result in
            switch result {
            case let .success(data):
                let parseResult: Result<T, Error> = parseData(data)
                completion(parseResult)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // 实际执行 PUT 请求
    private static func performRequestPut<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        print("request put tsp:", path, parameters, tspHeaders)
        NetworkManager.shared.requestPut(path: AppGlobalState.shared.tspUrl + path, parameters: parameters, headers: tspHeaders) { result in
            switch result {
            case let .success(data):
                let parseResult: Result<T, Error> = parseData(data)
                completion(parseResult)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    static func uploadCos(url: String, image: UIImage, parameters: Parameters, completion: @escaping (Result<String, Error>) -> Void) {
        NetworkManager.shared.uploadImg(image: image, to: AppGlobalState.shared.tspUrl + url, params: parameters) { result in
            switch result {
            case .success(_):
                completion(.success(""))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // json -> model
    static func parseData<T: Decodable>(_ data: Data) -> Result<T, Error> {
        let decoder = JSONDecoder()
        
        let dataStr = String(data: data, encoding: .utf8)!
        print("response tsp:", dataStr)
        
        guard let decodedData = try? decoder.decode(T.self, from: data) else {
            let error = NSError(domain: "NetworkAPIError", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Can not parse data"])
            return .failure(error)
        }
        return .success(decodedData)
    }
    
    // model -> dic
    static func model2Dic<T: Encodable>(_ model: T) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(model) else {
            return nil
        }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else {
            return nil
        }
        return dict
    }

}
