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
