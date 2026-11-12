//
//  TspNetworkManager.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation
import Alamofire
import UIKit

typealias NetworkRequestResult = Result<Data, Error>
typealias NetworkRequestCompletion = (NetworkRequestResult) -> Void

// 网络模块,设计为单例模式
class NetworkManager {
    // 共享对象
    static let shared = NetworkManager()

    /// 实际发起请求的 Session；测试可注入带 `URLProtocol` 替身的 Session
    let session: Session

    init(session: Session = Session.default) {
        self.session = session
    }
    
    @discardableResult
    func requestGet(path: String,
                    parameters: Parameters?,
                    headers: HTTPHeaders?,
                    // @escaping,逃逸闭包: 一个闭包被作为一个参数传递给一个函数，并且在函数return之后才被唤起执行
                    completion: @escaping NetworkRequestCompletion) -> DataRequest {
        logRequest(method: "GET", url: path)
        return session.request(path,
                   parameters: parameters,
                   headers: headers,
                   requestModifier: { $0.timeoutInterval = 30 })
            .responseData { response in
                self.logResponse(method: "GET", url: path, statusCode: response.response?.statusCode)
                switch response.result {
                case let .success(data): completion(.success(data))
                case let .failure(error): completion(self.handleError(error))
                }
            }
    }
    
    @discardableResult
    func requestPost(path: String,
                     parameters: Parameters?,
                     headers: HTTPHeaders?,
                     completion: @escaping NetworkRequestCompletion) -> DataRequest {
        logRequest(method: "POST", url: path)
        return session.request(path,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.prettyPrinted, // parameters的编码方式,默认为JSON
//                   encoding: URLEncoding.default, // parameters的编码方式,默认为JSON
                   headers: headers,
                   requestModifier: { $0.timeoutInterval = 30 })
            .responseData { response in
                // 请求发送成功与失败
                self.logResponse(method: "POST", url: path, statusCode: response.response?.statusCode)
                switch response.result {
                case let .success(data): completion(.success(data))
                case let .failure(error): completion(self.handleError(error))
                }
            }
    }
    
    @discardableResult
    func requestPut(path: String,
                    parameters: Parameters?,
                    headers: HTTPHeaders?,
                    completion: @escaping NetworkRequestCompletion) -> DataRequest {
        logRequest(method: "PUT", url: path)
        return session.request(path,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.prettyPrinted,
                   headers: headers,
                   requestModifier: { $0.timeoutInterval = 30 })
            .responseData { response in
                self.logResponse(method: "PUT", url: path, statusCode: response.response?.statusCode)
                switch response.result {
                case let .success(data): completion(.success(data))
                case let .failure(error): completion(self.handleError(error))
                }
            }
    }

    // MARK: - 诊断日志（不含敏感数据）

    private func logRequest(method: String, url: String) {
        SafeLog.log("HTTP", method, url)
    }

    private func logResponse(method: String, url: String, statusCode: Int?) {
        SafeLog.log("HTTP", method, url, "status:", statusCode.map(String.init) ?? "nil")
    }

    /// 预签名直传（IOS-APP-DSN-CR-003 RD-003-3）
    /// - 使用绝对 `uploadUrl` 原值，不做域名拼接、不改写 query
    /// - 仅发送 `Content-Type`，不携带任何业务凭证头
    /// - 返回 HTTP 状态码，非 2xx 由调用方判定为失败
    @discardableResult
    func putBinary(url: String,
                   data: Data,
                   contentType: String,
                   completion: @escaping (Result<Int, Error>) -> Void) -> DataRequest {
        // 预签名地址含签名 query，日志只保留 host + path
        logRequest(method: "PUT", url: Self.redactedURL(url))
        var request = URLRequest(url: URL(string: url) ?? URL(string: "about:blank")!)
        request.method = HTTPMethod.put
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        request.httpBody = data

        // 只关心状态码：COS 成功响应通常为空体，避免 `responseData` 把空体当序列化失败
        return session.request(request)
            .response { response in
                self.logResponse(method: "PUT", url: Self.redactedURL(url), statusCode: response.response?.statusCode)
                if let error = response.error {
                    completion(.failure(self.mappedError(error)))
                    return
                }
                completion(.success(response.response?.statusCode ?? 0))
            }
    }

    /// 去掉 query 的日志安全地址（禁止记录预签名参数）
    static func redactedURL(_ url: String) -> String {
        guard let index = url.firstIndex(of: "?") else { return url }
        return String(url[..<index]) + "?***"
    }
    
    /// 归一化网络错误为 `Error`
    private func mappedError(_ error: AFError) -> Error {
        switch handleError(error) {
        case let .failure(mapped): return mapped
        case .success: return error
        }
    }

    // 处理网络请求中的错误
    private func handleError(_ error: AFError) -> NetworkRequestResult {
        if let underlyingError = error.underlyingError {
            let nserror = underlyingError as NSError
            let code = nserror.code
            if  code == NSURLErrorNotConnectedToInternet ||
                    code == NSURLErrorTimedOut ||
                    code == NSURLErrorInternationalRoamingOff ||
                    code == NSURLErrorDataNotAllowed ||
                    code == NSURLErrorCannotFindHost ||
                    code == NSURLErrorCannotConnectToHost ||
                    code == NSURLErrorNetworkConnectionLost {
                var userInfo = nserror.userInfo
                userInfo[NSLocalizedDescriptionKey] = "网络连接有问题喔～"
                let currentError = NSError(domain: nserror.domain, code: code, userInfo: userInfo)
                return .failure(currentError)
            }
        }
        return .failure(error)
    }
    
}
