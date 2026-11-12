//
//  AvatarRemoteAPI.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-003 on 2026/11/12.
//

import Foundation
import Alamofire

// MARK: - 错误

/// 头像上传错误语义（IOS-APP-DSN-CR-003 §5.4）
enum AvatarUploadError: Error, Equatable {
    /// 端上预处理失败
    case preprocessFailed(AvatarImageError)
    /// 申请响应不合法 / 申请失败（需重新走完整流程）
    case invalidTicket
    /// 直传失败（保留旧头像，可重试）
    case uploadFailed
    /// 确认失败；`retryable` 为真时可自动重试一次
    case confirmFailed(retryable: Bool)
    /// 701110 上传任务不存在或已过期：重新申请，不复用旧 uploadId
    case taskExpired
    /// 701111 无权确认
    case forbidden
    /// 会话失效，交由全局会话流程处理
    case unauthorized
    /// 用户取消
    case cancelled
    /// 上传进行中，忽略重复触发
    case inProgress
}

/// 头像上传相关业务码（SEC-CIAM-DSN-CR-004 §6.3）
enum AvatarServerCode {
    static let uploadNotFound = "701110"
    static let uploadForbidden = "701111"
    static let imageServiceUnavailable = "701112"
}

// MARK: - 票据校验

/// 申请响应严格校验（IOS-APP-DSN-CR-003 RD-003-4）
enum AvatarTicketValidator {

    static let expectedContentType = "image/jpeg"
    static let expectedHTTPMethod = "PUT"

    static func isValid(_ ticket: AvatarUploadTicket, now: Date = Date()) -> Bool {
        guard !ticket.uploadId.isEmpty, !ticket.uploadUrl.isEmpty else { return false }
        guard ticket.httpMethod.uppercased() == expectedHTTPMethod else { return false }
        guard ticket.contentType == expectedContentType else { return false }
        return ticket.expiresAt > Int64(now.timeIntervalSince1970 * 1000)
    }
}

// MARK: - 远程契约

/// 头像上传三段式远程契约（申请 → 直传 → 确认）
protocol AvatarRemoteAPI {
    func requestTicket(
        _ request: AvatarUploadRequest,
        completion: @escaping (Result<AvatarUploadTicket, AvatarUploadError>) -> Void
    )
    func uploadBinary(
        url: String,
        data: Data,
        contentType: String,
        completion: @escaping (Result<Void, AvatarUploadError>) -> Void
    )
    func completeUpload(
        uploadId: String,
        completion: @escaping (Result<AvatarResult, AvatarUploadError>) -> Void
    )
}

// MARK: - 生产实现

/// 生产实现：复用现有请求头与 token 刷新语义（`TspManager.ensureTokenValid`）
final class AvatarRemoteAPIClient: AvatarRemoteAPI {

    static let shared = AvatarRemoteAPIClient()

    private let networkManager: NetworkManager
    private let baseURL: () -> String
    private let headers: () -> HTTPHeaders
    private let ensureSession: (@escaping (Result<Void, Error>) -> Void) -> Void
    private let now: () -> Date

    init(
        networkManager: NetworkManager = .shared,
        baseURL: @escaping () -> String = { AppGlobalState.shared.tspUrl },
        headers: @escaping () -> HTTPHeaders = { tspHeaders },
        ensureSession: @escaping (@escaping (Result<Void, Error>) -> Void) -> Void = { completion in
            TspManager.ensureTokenValid(completion: completion)
        },
        now: @escaping () -> Date = Date.init
    ) {
        self.networkManager = networkManager
        self.baseURL = baseURL
        self.headers = headers
        self.ensureSession = ensureSession
        self.now = now
    }

    func requestTicket(
        _ request: AvatarUploadRequest,
        completion: @escaping (Result<AvatarUploadTicket, AvatarUploadError>) -> Void
    ) {
        guard let parameters = TspManager.model2Dic(request) else {
            completion(.failure(.invalidTicket))
            return
        }

        withSession { result in
            switch result {
            case .failure:
                completion(.failure(.unauthorized))
            case .success:
                self.networkManager.requestPost(
                    path: self.baseURL() + Self.uploadPath,
                    parameters: parameters,
                    headers: self.headers()
                ) { result in
                    switch result {
                    case .failure:
                        completion(.failure(.invalidTicket))
                    case let .success(data):
                        let parsed: Result<TspResponse<AvatarUploadTicket>, Error> = TspManager.parseData(data)
                        switch parsed {
                        case .failure:
                            completion(.failure(.invalidTicket))
                        case let .success(response):
                            guard response.isSuccess, let ticket = response.data else {
                                completion(.failure(self.mapBusinessError(response.code, confirmPhase: false)))
                                return
                            }
                            guard AvatarTicketValidator.isValid(ticket, now: self.now()) else {
                                completion(.failure(.invalidTicket))
                                return
                            }
                            completion(.success(ticket))
                        }
                    }
                }
            }
        }
    }

    func uploadBinary(
        url: String,
        data: Data,
        contentType: String,
        completion: @escaping (Result<Void, AvatarUploadError>) -> Void
    ) {
        // 直传不经过 SGW、不携带业务凭证、不改写 query（RD-003-3）
        networkManager.putBinary(url: url, data: data, contentType: contentType) { result in
            switch result {
            case let .success(status):
                if (200...299).contains(status) {
                    completion(.success(()))
                } else {
                    SafeLog.log("avatar put failed, status:", status, "uploadIdHost:", URL(string: url)?.host ?? "")
                    completion(.failure(.uploadFailed))
                }
            case .failure:
                completion(.failure(.uploadFailed))
            }
        }
    }

    func completeUpload(
        uploadId: String,
        completion: @escaping (Result<AvatarResult, AvatarUploadError>) -> Void
    ) {
        guard !uploadId.isEmpty else {
            completion(.failure(.taskExpired))
            return
        }

        withSession { result in
            switch result {
            case .failure:
                completion(.failure(.unauthorized))
            case .success:
                self.networkManager.requestPost(
                    path: self.baseURL() + Self.completePath(uploadId: uploadId),
                    parameters: [:],
                    headers: self.headers()
                ) { result in
                    switch result {
                    case .failure:
                        completion(.failure(.confirmFailed(retryable: true)))
                    case let .success(data):
                        let parsed: Result<TspResponse<AvatarResult>, Error> = TspManager.parseData(data)
                        switch parsed {
                        case .failure:
                            completion(.failure(.confirmFailed(retryable: true)))
                        case let .success(response):
                            guard response.isSuccess else {
                                completion(.failure(self.mapBusinessError(response.code, confirmPhase: true)))
                                return
                            }
                            guard let avatar = response.data, !avatar.avatarUrl.isEmpty else {
                                completion(.failure(.confirmFailed(retryable: false)))
                                return
                            }
                            completion(.success(avatar))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Private

    private func withSession(_ completion: @escaping (Result<Void, Error>) -> Void) {
        ensureSession(completion)
    }

    private func mapBusinessError(_ code: String, confirmPhase: Bool) -> AvatarUploadError {
        switch code {
        case AuthServerCode.sessionExpired:
            return .unauthorized
        case AvatarServerCode.uploadNotFound:
            return confirmPhase ? .taskExpired : .invalidTicket
        case AvatarServerCode.uploadForbidden:
            return .forbidden
        case AvatarServerCode.imageServiceUnavailable:
            return confirmPhase ? .confirmFailed(retryable: true) : .invalidTicket
        default:
            return confirmPhase ? .confirmFailed(retryable: false) : .invalidTicket
        }
    }

    static let uploadPath = "/api/mobile/account/v1/profile/avatar/upload"

    static func completePath(uploadId: String) -> String {
        return "/api/mobile/account/v1/profile/avatar/\(uploadId)/complete"
    }
}

// MARK: - TspApi 适配

/// 生产远程实现：经 `TspApi` 统一入口调用，便于与其他接口保持一致
struct TspAvatarRemoteAPI: AvatarRemoteAPI {
    func requestTicket(
        _ request: AvatarUploadRequest,
        completion: @escaping (Result<AvatarUploadTicket, AvatarUploadError>) -> Void
    ) {
        TspApi.requestAvatarUpload(request: request, completion: completion)
    }

    func uploadBinary(
        url: String,
        data: Data,
        contentType: String,
        completion: @escaping (Result<Void, AvatarUploadError>) -> Void
    ) {
        TspApi.putAvatarBinary(url: url, data: data, contentType: contentType, completion: completion)
    }

    func completeUpload(
        uploadId: String,
        completion: @escaping (Result<AvatarResult, AvatarUploadError>) -> Void
    ) {
        TspApi.completeAvatarUpload(uploadId: uploadId, completion: completion)
    }
}
