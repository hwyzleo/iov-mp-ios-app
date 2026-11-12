//
//  AvatarUploadService.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-003 on 2026/11/12.
//

import Foundation
import UIKit

typealias AvatarUploadCompletion = (Result<AvatarResult, AvatarUploadError>) -> Void

/// 头像上传编排（IOS-APP-DSN-CR-003 RD-003-1、5、7）
protocol AvatarUploading: AnyObject {
    var isUploading: Bool { get }
    /// 申请 → 直传 → 确认；上传中重复调用返回 `.inProgress`
    func upload(_ input: AvatarCropInput, completion: @escaping AvatarUploadCompletion)
    /// 用户取消/离开页面：停止自动重试，不修改本地头像
    func cancel()
}

/// 三段式直传编排：预处理 → 申请 → 直传 → 确认（失败自动重试一次）
final class AvatarUploadService: AvatarUploading {

    static let originalFilename = "avatar.jpg"
    static let contentType = "image/jpeg"
    /// 确认阶段自动重试次数
    static let maxConfirmRetries = 1

    private let remote: AvatarRemoteAPI
    private let processor: AvatarImageProcessing
    private let retryDelay: TimeInterval

    private(set) var isUploading = false
    private var cancelled = false
    private var generation = 0
    private var activeCompletion: AvatarUploadCompletion?

    init(
        remote: AvatarRemoteAPI = TspAvatarRemoteAPI(),
        processor: AvatarImageProcessing = AvatarImageProcessor(),
        retryDelay: TimeInterval = 0.4
    ) {
        self.remote = remote
        self.processor = processor
        self.retryDelay = retryDelay
    }

    func upload(_ input: AvatarCropInput, completion: @escaping AvatarUploadCompletion) {
        guard !isUploading else {
            completion(.failure(.inProgress))
            return
        }

        isUploading = true
        cancelled = false
        generation += 1
        activeCompletion = completion
        let token = generation

        switch processor.makeJPEG(from: input) {
        case let .failure(error):
            finish(.failure(.preprocessFailed(error)), token: token)
        case let .success(output):
            requestTicket(size: output.data.count, data: output.data, token: token)
        }
    }

    func cancel() {
        guard isUploading else { return }
        cancelled = true
        isUploading = false
        generation += 1
        activeCompletion = nil
    }

    // MARK: - Flow

    private func requestTicket(size: Int, data: Data, token: Int) {
        guard isActive(token) else { return }
        let request = AvatarUploadRequest(
            originalFilename: Self.originalFilename,
            contentType: Self.contentType,
            size: size
        )

        remote.requestTicket(request) { [weak self] result in
            guard let self = self else { return }
            self.runOnMain {
                guard self.isActive(token) else { return }
                switch result {
                case let .failure(error):
                    self.finish(.failure(error), token: token)
                case let .success(ticket):
                    self.uploadBinary(ticket: ticket, data: data, token: token)
                }
            }
        }
    }

    private func uploadBinary(ticket: AvatarUploadTicket, data: Data, token: Int) {
        guard isActive(token) else { return }
        // 直传失败不改写本地头像，也不再调用确认（TC-003-5）
        remote.uploadBinary(url: ticket.uploadUrl, data: data, contentType: ticket.contentType) { [weak self] result in
            guard let self = self else { return }
            self.runOnMain {
                guard self.isActive(token) else { return }
                switch result {
                case let .failure(error):
                    self.finish(.failure(error), token: token)
                case .success:
                    self.confirm(uploadId: ticket.uploadId, attempt: 0, token: token)
                }
            }
        }
    }

    private func confirm(uploadId: String, attempt: Int, token: Int) {
        guard isActive(token) else { return }

        remote.completeUpload(uploadId: uploadId) { [weak self] result in
            guard let self = self else { return }
            self.runOnMain {
                guard self.isActive(token) else { return }
                switch result {
                case let .success(avatar):
                    self.finish(.success(avatar), token: token)
                case let .failure(error):
                    if case let .confirmFailed(retryable) = error,
                       retryable,
                       attempt < Self.maxConfirmRetries {
                        self.scheduleRetry(token: token) {
                            self.confirm(uploadId: uploadId, attempt: attempt + 1, token: token)
                        }
                    } else {
                        self.finish(.failure(error), token: token)
                    }
                }
            }
        }
    }

    // MARK: - Private

    private func isActive(_ token: Int) -> Bool {
        return !cancelled && token == generation && isUploading
    }

    private func finish(_ result: Result<AvatarResult, AvatarUploadError>, token: Int) {
        guard token == generation else { return }
        isUploading = false
        let completion = activeCompletion
        activeCompletion = nil
        completion?(result)
    }

    private func scheduleRetry(token: Int, action: @escaping () -> Void) {
        if retryDelay <= 0 {
            runOnMain {
                guard self.isActive(token) else { return }
                action()
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
            guard let self = self, self.isActive(token) else { return }
            action()
        }
    }

    private func runOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}

// MARK: - 错误文案

/// 错误提示文案（失败复用现有 `displayError` 通道）
enum AvatarUploadErrorMessage {

    static func text(for error: AvatarUploadError) -> String? {
        switch error {
        case .preprocessFailed(let imageError):
            switch imageError {
            case .tooLarge:
                return "图片过大，请重新选择"
            case .decodeFailed, .renderFailed:
                return "图片处理失败，请重新选择"
            }
        case .invalidTicket:
            return "获取上传凭证失败，请重试"
        case .uploadFailed:
            return "头像上传失败，请重试"
        case .confirmFailed:
            return "头像更新失败，请稍后重试"
        case .taskExpired:
            return "上传已过期，请重试"
        case .forbidden:
            return "头像更新失败，请重试"
        case .unauthorized:
            // 交给全局会话失效流程，不重复提示
            return nil
        case .cancelled, .inProgress:
            return nil
        }
    }
}
