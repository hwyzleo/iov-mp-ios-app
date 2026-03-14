//
//  LoginService.swift
//  iov
//
//  Created by Gemini on 2026/3/14.
//

import Foundation

/// 登录业务服务协议
protocol LoginServiceProtocol {
    func sendMobileVerifyCode(countryRegionCode: String, mobile: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
    func mobileVerifyCodeLogin(countryRegionCode: String, mobile: String, verifyCode: String, completion: @escaping (Result<TspResponse<LoginResponse>, Error>) -> Void)
}

/// 真实的 TSP API 实现
class RealLoginService: LoginServiceProtocol {
    func sendMobileVerifyCode(countryRegionCode: String, mobile: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.sendMobileVerifyCode(countryRegionCode: countryRegionCode, mobile: mobile, completion: completion)
    }
    
    func mobileVerifyCodeLogin(countryRegionCode: String, mobile: String, verifyCode: String, completion: @escaping (Result<TspResponse<LoginResponse>, Error>) -> Void) {
        TspApi.mobileVerifyCodeLogin(countryRegionCode: countryRegionCode, mobile: mobile, verifyCode: verifyCode, completion: completion)
    }
}

/// Mock 数据实现
class MockLoginService: LoginServiceProtocol {
    func sendMobileVerifyCode(countryRegionCode: String, mobile: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        // Mock 总是成功
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let response = TspResponse<NoReply>(code: 0, message: "Success", ts: Int64(Date().timeIntervalSince1970 * 1000), data: nil)
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }
    
    func mobileVerifyCodeLogin(countryRegionCode: String, mobile: String, verifyCode: String, completion: @escaping (Result<TspResponse<LoginResponse>, Error>) -> Void) {
        // Mock 总是登录成功，返回模拟的 LoginResponse
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockData = mockLoginResponse()
            let response = TspResponse(code: 0, message: "Success", ts: Int64(Date().timeIntervalSince1970 * 1000), data: mockData)
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }
}
