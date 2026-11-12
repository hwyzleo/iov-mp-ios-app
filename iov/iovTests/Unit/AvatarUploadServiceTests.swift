//
//  AvatarUploadServiceTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-003 on 2026/11/12.
//

import XCTest
import UIKit
@testable import iov

final class AvatarUploadServiceTests: XCTestCase {

    private func makeInput(size: Int = 2048) -> (AvatarCropInput, AvatarImageOutput) {
        let image = UIImage()
        let output = AvatarImageOutput(
            data: Data(repeating: 0xAB, count: size),
            quality: 0.8,
            pixelSize: CGSize(width: 1024, height: 1024)
        )
        return (AvatarCropInput(image: image, cropSide: 280, scale: 1, offset: .zero), output)
    }

    private func makeTicket(expiresIn: TimeInterval = 600) -> AvatarUploadTicket {
        return AvatarUploadTicket(
            uploadId: "upload-1",
            uploadUrl: "https://bucket.cos.example.com/images/sec-ciam/a.jpg?sign=abc",
            httpMethod: "PUT",
            contentType: "image/jpeg",
            expiresAt: Int64((Date().addingTimeInterval(expiresIn)).timeIntervalSince1970 * 1000)
        )
    }

    private func makeAvatar() -> AvatarResult {
        return AvatarResult(
            avatarUrl: "https://bucket.cos.example.com/images/sec-ciam/a.jpg",
            objectId: "upload-1",
            contentType: "image/jpeg",
            size: 2048
        )
    }

    // MARK: - TC-003-2 / 3

    func testUploadSuccessRunsThreePhases() {
        let (input, output) = makeInput()
        let remote = FakeAvatarRemoteAPI()
        let ticket = makeTicket()
        remote.ticketResult = .success(ticket)
        remote.uploadResults = [.success(())]
        remote.completeResults = [.success(makeAvatar())]
        let service = AvatarUploadService(remote: remote, processor: FakeAvatarImageProcessor(result: .success(output)), retryDelay: 0)

        let expectation = expectation(description: "upload")
        var received: Result<AvatarResult, AvatarUploadError>?
        service.upload(input) { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(remote.ticketRequests.count, 1)
        XCTAssertEqual(remote.ticketRequests.first?.originalFilename, "avatar.jpg")
        XCTAssertEqual(remote.ticketRequests.first?.contentType, "image/jpeg")
        XCTAssertEqual(remote.ticketRequests.first?.size, output.data.count)

        XCTAssertEqual(remote.uploadCalls.count, 1)
        XCTAssertEqual(remote.uploadCalls.first?.url, ticket.uploadUrl)
        XCTAssertEqual(remote.uploadCalls.first?.contentType, "image/jpeg")
        XCTAssertEqual(remote.uploadCalls.first?.data, output.data)

        XCTAssertEqual(remote.completeCalls, [ticket.uploadId])
        guard case let .success(avatar)? = received else {
            return XCTFail("应返回成功结果: \(String(describing: received))")
        }
        XCTAssertEqual(avatar.avatarUrl, makeAvatar().avatarUrl)
        XCTAssertFalse(service.isUploading)
    }

    func testInvalidTicketSkipsDirectUpload() {
        let (input, output) = makeInput()
        let remote = FakeAvatarRemoteAPI()
        remote.ticketResult = .failure(.invalidTicket)
        let service = AvatarUploadService(remote: remote, processor: FakeAvatarImageProcessor(result: .success(output)), retryDelay: 0)

        let expectation = expectation(description: "invalid ticket")
        var received: Result<AvatarResult, AvatarUploadError>?
        service.upload(input) { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertTrue(remote.uploadCalls.isEmpty)
        XCTAssertTrue(remote.completeCalls.isEmpty)
        XCTAssertEqual(received ?? .failure(.cancelled), .failure(.invalidTicket))
        XCTAssertFalse(service.isUploading)
    }

    // MARK: - TC-003-5

    func testDirectUploadFailureSkipsConfirm() {
        let (input, output) = makeInput()
        let remote = FakeAvatarRemoteAPI()
        remote.ticketResult = .success(makeTicket())
        remote.uploadResults = [.failure(.uploadFailed)]
        let service = AvatarUploadService(remote: remote, processor: FakeAvatarImageProcessor(result: .success(output)), retryDelay: 0)

        let expectation = expectation(description: "upload failure")
        var received: Result<AvatarResult, AvatarUploadError>?
        service.upload(input) { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(remote.uploadCalls.count, 1)
        XCTAssertTrue(remote.completeCalls.isEmpty, "直传失败不得调用确认")
        XCTAssertEqual(received ?? .failure(.cancelled), .failure(.uploadFailed))
    }

    // MARK: - TC-003-6 / 7

    func testConfirmRetriesOnceWithSameUploadId() {
        let (input, output) = makeInput()
        let remote = FakeAvatarRemoteAPI()
        let ticket = makeTicket()
        remote.ticketResult = .success(ticket)
        remote.uploadResults = [.success(())]
        remote.completeResults = [
            .failure(.confirmFailed(retryable: true)),
            .success(makeAvatar())
        ]
        let service = AvatarUploadService(remote: remote, processor: FakeAvatarImageProcessor(result: .success(output)), retryDelay: 0)

        let expectation = expectation(description: "confirm retry")
        var received: Result<AvatarResult, AvatarUploadError>?
        service.upload(input) { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(remote.completeCalls, [ticket.uploadId, ticket.uploadId])
        guard case let .success(avatar)? = received else {
            return XCTFail("重试后应成功: \(String(describing: received))")
        }
        XCTAssertEqual(avatar.avatarUrl, makeAvatar().avatarUrl)
    }

    func testConfirmFailsTwiceKeepsFailure() {
        let (input, output) = makeInput()
        let remote = FakeAvatarRemoteAPI()
        remote.ticketResult = .success(makeTicket())
        remote.uploadResults = [.success(())]
        remote.completeResults = [
            .failure(.confirmFailed(retryable: true)),
            .failure(.confirmFailed(retryable: true))
        ]
        let service = AvatarUploadService(remote: remote, processor: FakeAvatarImageProcessor(result: .success(output)), retryDelay: 0)

        let expectation = expectation(description: "confirm failure")
        var received: Result<AvatarResult, AvatarUploadError>?
        service.upload(input) { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(remote.completeCalls.count, 2)
        XCTAssertEqual(received ?? .failure(.cancelled), .failure(.confirmFailed(retryable: true)))
        XCTAssertFalse(service.isUploading)
    }

    // MARK: - TC-003-8

    func testTaskExpiredIsNotRetried() {
        let (input, output) = makeInput()
        let remote = FakeAvatarRemoteAPI()
        remote.ticketResult = .success(makeTicket())
        remote.uploadResults = [.success(())]
        remote.completeResults = [.failure(.taskExpired), .success(makeAvatar())]
        let service = AvatarUploadService(remote: remote, processor: FakeAvatarImageProcessor(result: .success(output)), retryDelay: 0)

        let expectation = expectation(description: "task expired")
        var received: Result<AvatarResult, AvatarUploadError>?
        service.upload(input) { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(remote.completeCalls.count, 1)
        XCTAssertEqual(received ?? .failure(.cancelled), .failure(.taskExpired))
    }

    // MARK: - TC-003-9

    func testDuplicateTriggerRequestsOnlyOnce() {
        let (input, output) = makeInput()
        let remote = FakeAvatarRemoteAPI()
        remote.holdTicket = true
        let service = AvatarUploadService(remote: remote, processor: FakeAvatarImageProcessor(result: .success(output)), retryDelay: 0)

        var secondResult: Result<AvatarResult, AvatarUploadError>?
        service.upload(input) { _ in }
        service.upload(input) { result in
            secondResult = result
        }

        XCTAssertEqual(secondResult ?? .failure(.cancelled), .failure(.inProgress))
        XCTAssertEqual(remote.ticketRequests.count, 1)

        // 释放挂起的申请，避免悬挂
        let done = expectation(description: "released")
        remote.completePendingTicket(with: .failure(.invalidTicket))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { done.fulfill() }
        wait(for: [done], timeout: 2)
    }

    // MARK: - 取消与生命周期

    func testCancelStopsFlowAndIgnoresLateResult() {
        let (input, output) = makeInput()
        let remote = FakeAvatarRemoteAPI()
        remote.holdTicket = true
        let service = AvatarUploadService(remote: remote, processor: FakeAvatarImageProcessor(result: .success(output)), retryDelay: 0)

        var completionCalled = false
        service.upload(input) { _ in completionCalled = true }
        service.cancel()
        remote.completePendingTicket(with: .success(makeTicket()))

        let settled = expectation(description: "settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { settled.fulfill() }
        wait(for: [settled], timeout: 2)

        XCTAssertFalse(completionCalled, "取消后不再回调")
        XCTAssertTrue(remote.uploadCalls.isEmpty, "取消后不得继续直传")
        XCTAssertFalse(service.isUploading)
    }

    func testPreprocessFailureDoesNotRequestTicket() {
        let (input, _) = makeInput()
        let remote = FakeAvatarRemoteAPI()
        let service = AvatarUploadService(
            remote: remote,
            processor: FakeAvatarImageProcessor(result: .failure(.tooLarge(maxBytes: 10))),
            retryDelay: 0
        )

        let expectation = expectation(description: "preprocess")
        var received: Result<AvatarResult, AvatarUploadError>?
        service.upload(input) { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertTrue(remote.ticketRequests.isEmpty)
        XCTAssertEqual(received ?? .failure(.cancelled), .failure(.preprocessFailed(.tooLarge(maxBytes: 10))))
    }
}

// MARK: - Fakes

struct FakeAvatarImageProcessor: AvatarImageProcessing {
    let result: Result<AvatarImageOutput, AvatarImageError>

    func makeJPEG(from input: AvatarCropInput) -> Result<AvatarImageOutput, AvatarImageError> {
        return result
    }
}

final class FakeAvatarRemoteAPI: AvatarRemoteAPI {

    var ticketResult: Result<AvatarUploadTicket, AvatarUploadError> = .failure(.invalidTicket)
    var uploadResults: [Result<Void, AvatarUploadError>] = []
    var completeResults: [Result<AvatarResult, AvatarUploadError>] = []
    var holdTicket = false

    private(set) var ticketRequests: [AvatarUploadRequest] = []
    private(set) var uploadCalls: [(url: String, data: Data, contentType: String)] = []
    private(set) var completeCalls: [String] = []
    private var pendingTicket: ((Result<AvatarUploadTicket, AvatarUploadError>) -> Void)?

    func requestTicket(
        _ request: AvatarUploadRequest,
        completion: @escaping (Result<AvatarUploadTicket, AvatarUploadError>) -> Void
    ) {
        ticketRequests.append(request)
        if holdTicket {
            pendingTicket = completion
            return
        }
        completion(ticketResult)
    }

    func completePendingTicket(with result: Result<AvatarUploadTicket, AvatarUploadError>) {
        let completion = pendingTicket
        pendingTicket = nil
        completion?(result)
    }

    func uploadBinary(
        url: String,
        data: Data,
        contentType: String,
        completion: @escaping (Result<Void, AvatarUploadError>) -> Void
    ) {
        uploadCalls.append((url, data, contentType))
        completion(uploadResults.isEmpty ? .failure(.uploadFailed) : uploadResults.removeFirst())
    }

    func completeUpload(
        uploadId: String,
        completion: @escaping (Result<AvatarResult, AvatarUploadError>) -> Void
    ) {
        completeCalls.append(uploadId)
        completion(completeResults.isEmpty ? .failure(.confirmFailed(retryable: false)) : completeResults.removeFirst())
    }
}
