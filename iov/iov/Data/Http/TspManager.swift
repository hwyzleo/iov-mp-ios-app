//
//  BaseAPI.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation
import Alamofire
import UIKit

// TSP 公共请求头（不含凭证）
var tspBaseHeaders: HTTPHeaders {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

    return [
        "X-Device-Id": getDeviceId(),
        "X-Platform": "ios",
        "X-Os-Version": UIDevice.current.systemVersion,
        "X-App-Version": appVersion,
        "X-Client-Id": AppConfig.tspClientId,
        "X-Client-Type": "MOBILE"
    ]
}

// TSP 请求头（凭证仅从 Keychain 会话读取）
var tspHeaders: HTTPHeaders {
    let token = AuthEnvironment.shared.sessionRepository.currentAccessToken()

    var headers = tspBaseHeaders
    if !token.isEmpty {
        headers["Authorization"] = "Bearer \(token)"
    }

    return headers
}

/// TSP 管理
class TspManager {
    
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
    
    // 确保 token 有效（单飞刷新由 TokenRefreshCoordinator 负责）
    static func ensureTokenValid(completion: @escaping (Result<Void, Error>) -> Void) {
        let repository = AuthEnvironment.shared.sessionRepository
        guard repository.hasSession() else {
            completion(.success(()))
            return
        }

        guard repository.isAccessTokenExpiring(within: 300) else {
            completion(.success(()))
            return
        }

        SafeLog.log("access_token 即将过期，开始刷新")
        AuthEnvironment.shared.refreshCoordinator.refresh { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                // 会话失效由 TokenRefreshCoordinator 统一发布 sessionExpired 事件
                SafeLog.log("access_token 刷新失败:", error.logCategory)
                completion(.failure(error))
            }
        }
    }
    
    // 实际执行 POST 请求
    private static func performRequestPost<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        SafeLog.log("request post tsp:", path, SafeLog.redacted(parameters: parameters), SafeLog.redacted(headers: tspHeaders))
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
        SafeLog.log("request get tsp:", path, SafeLog.redacted(parameters: parameters), SafeLog.redacted(headers: tspHeaders))
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
        SafeLog.log("request put tsp:", path, SafeLog.redacted(parameters: parameters), SafeLog.redacted(headers: tspHeaders))
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
    
    // json -> model
    static func parseData<T: Decodable>(_ data: Data) -> Result<T, Error> {
        let decoder = JSONDecoder()

        let dataStr = String(data: data, encoding: .utf8) ?? "<unreadable response>"
        SafeLog.log("response tsp:", SafeLog.redacted(responseBody: dataStr))

        if let rawResponse = try? decoder.decode(TspResponse<AnyCodable>.self, from: data),
           rawResponse.code == AuthServerCode.sessionExpired {
            DispatchQueue.main.async {
                AuthEnvironment.shared.handleSessionExpired()
            }
        }
        
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
