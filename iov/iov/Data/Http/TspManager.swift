//
//  BaseAPI.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation
import Alamofire
import UIKit

/// TSP管理
class TspManager {
    
    // POST请求
    static func requestPost<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        NetworkManager.shared.requestPost(path: AppGlobalState.shared.tspUrl + path, parameters: parameters) { result in
            switch result {
            case let.success(data):
                let parseResult: Result<T, Error> = parseData(data)
                completion(parseResult)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // GET请求
    static func requestGet<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        NetworkManager.shared.requestGet(path: AppGlobalState.shared.tspUrl + path, parameters: parameters) { result in
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
        print(dataStr)
        
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
