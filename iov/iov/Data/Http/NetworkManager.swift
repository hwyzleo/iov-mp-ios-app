//
//  NetworkManager.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation
import Alamofire
import UIKit

typealias NetworkRequestResult = Result<String, Error>
typealias NetworkRequestCompletion = (NetworkRequestResult) -> Void

// 网络模块,设计为单例模式
class NetworkManager {
    // 共享对象
    static let shared = NetworkManager()
    
    // 获取有token的请求头
    // 你应当在合适的时机, 将 token 存入 UserDefaults 中
    var commonHeaders: HTTPHeaders { [
        "token": UserDefaults.standard.string(forKey: "token") ?? "",
        "clientId": UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    ] }
    
    private init() {} // 外部无法使用该类创建该对象

    // 图片上传
    @discardableResult
    func uploadImg(image: UIImage,
                   url: String,
                   params: [String: Any],
                   completion: @escaping NetworkRequestCompletion) -> DataRequest
    {
        let imageData = image.jpegData(compressionQuality: 0.5)
        var uploadHeaders:HTTPHeaders = [:]
        uploadHeaders["Content-Type"] = "image/jpeg; charset=utf-8"
        uploadHeaders["Content-Length"] = String(imageData!.count)
        let stream = InputStream(data: imageData!)
        let request = AF.upload(stream, to: url, method: .put, headers: uploadHeaders)
            .responseData { _ in
                completion(.success(""))
            }
        return request
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
