//
//  AvatarContractTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-003 on 2026/11/12.
//

import XCTest
import UIKit
import Alamofire
@testable import iov

/// 头像上传契约测试（IOS-APP-DSN-CR-003 §5 / TC-003-2、3、4、5）
final class AvatarContractTests: XCTestCase {

    override func tearDown() {
        StubURLProtocol.reset()
        super.tearDown()
    }

    // MARK: - TC-003-2 申请

    func testRequestTicketSendsContractBodyAndParsesFiveFields() {
        StubURLProtocol.handler = { _ in
            .json(tspEnvelope(data: avatarTicketPayload()))
        }
        let client = makeStubbedAvatarClient(networkManager: makeStubbedNetworkManager())

        let expectation = expectation(description: "ticket")
        var received: Result<AvatarUploadTicket, AvatarUploadError>?
        client.requestTicket(
            AvatarUploadRequest(originalFilename: "avatar.jpg", contentType: "image/jpeg", size: 204800)
        ) { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)

        let request = StubURLProtocol.requests.first
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.url?.absoluteString, "https://sgw.test/api/mobile/account/v1/profile/avatar/upload")
        XCTAssertEqual(request?.avatarTestHeader("Authorization"), "Bearer test-token")

        let body = request?.avatarTestJSONBody()
        XCTAssertEqual(body?["originalFilename"] as? String, "avatar.jpg")
        XCTAssertEqual(body?["contentType"] as? String, "image/jpeg")
        XCTAssertEqual(body?["size"] as? Int, 204800)

        guard case let .success(ticket)? = received else {
            return XCTFail("应解析成功: \(String(describing: received))")
        }
        XCTAssertEqual(ticket.uploadId, "upload-1")
        XCTAssertEqual(ticket.httpMethod, "PUT")
        XCTAssertEqual(ticket.contentType, "image/jpeg")
        XCTAssertGreaterThan(ticket.expiresAt, 0)
        XCTAssertTrue(ticket.uploadUrl.hasPrefix("https://bucket.cos.example.com"))
    }

    // MARK: - TC-003-3 申请响应非法

    func testRequestTicketRejectsInvalidTickets() {
        let cases: [(String, [String: Any], String)] = [
            ("httpMethod 非 PUT", avatarTicketPayload(httpMethod: "POST"), "000000"),
            ("contentType 非 image/jpeg", avatarTicketPayload(contentType: "image/png"), "000000"),
            ("已过期", avatarTicketPayload(expiresAt: Int64(Date().addingTimeInterval(-10).timeIntervalSince1970 * 1000)), "000000"),
            ("uploadId 为空", avatarTicketPayload(uploadId: ""), "000000"),
            ("业务码非成功", avatarTicketPayload(), "701112")
        ]

        for (name, payload, code) in cases {
            StubURLProtocol.reset()
            StubURLProtocol.handler = { _ in .json(tspEnvelope(code: code, data: payload)) }
            let client = makeStubbedAvatarClient(networkManager: makeStubbedNetworkManager())

            let expectation = expectation(description: name)
            var received: Result<AvatarUploadTicket, AvatarUploadError>?
            client.requestTicket(
                AvatarUploadRequest(originalFilename: "avatar.jpg", contentType: "image/jpeg", size: 1024)
            ) { result in
                received = result
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5)

            guard case .failure? = received else {
                return XCTFail("\(name) 应被拒绝: \(String(describing: received))")
            }
        }
    }

    func testRequestTicketRejectsMissingFields() {
        StubURLProtocol.handler = { _ in
            .json(tspEnvelope(data: ["uploadId": "upload-1"]))
        }
        let client = makeStubbedAvatarClient(networkManager: makeStubbedNetworkManager())

        let expectation = expectation(description: "missing fields")
        var received: Result<AvatarUploadTicket, AvatarUploadError>?
        client.requestTicket(
            AvatarUploadRequest(originalFilename: "avatar.jpg", contentType: "image/jpeg", size: 1024)
        ) { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)

        guard case .failure? = received else {
            return XCTFail("字段缺失应被拒绝")
        }
    }

    // MARK: - TC-003-4 直传形态

    func testDirectUploadUsesAbsoluteUrlWithoutCredentials() {
        let uploadUrl = "https://bucket.cos.example.com/images/sec-ciam/a.jpg?sign=abc&q=1"
        let jpeg = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x01, 0x02])
        StubURLProtocol.handler = { _ in .empty(status: 200) }
        let client = makeStubbedAvatarClient(networkManager: makeStubbedNetworkManager())

        let expectation = expectation(description: "put")
        var received: Result<Void, AvatarUploadError>?
        client.uploadBinary(url: uploadUrl, data: jpeg, contentType: "image/jpeg") { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)

        guard case .success? = received else {
            return XCTFail("直传应成功: \(String(describing: received))")
        }

        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.httpMethod, "PUT")
        XCTAssertEqual(request?.url?.absoluteString, uploadUrl, "必须原样使用绝对 uploadUrl，不拼接域名、不改写 query")
        XCTAssertEqual(request?.avatarTestHeader("Content-Type"), "image/jpeg")
        XCTAssertNil(request?.avatarTestHeader("Authorization"))
        XCTAssertNil(request?.avatarTestHeader("X-Client-Id"))
        XCTAssertNil(request?.avatarTestHeader("X-Device-Id"))
        XCTAssertEqual(request?.avatarTestBody, jpeg)
    }

    // MARK: - TC-003-5 直传失败

    func testDirectUploadNon2xxFails() {
        StubURLProtocol.handler = { _ in .empty(status: 403) }
        let client = makeStubbedAvatarClient(networkManager: makeStubbedNetworkManager())

        let expectation = expectation(description: "put 403")
        var received: Result<Void, AvatarUploadError>?
        client.uploadBinary(url: "https://bucket.cos.example.com/a.jpg?sign=x", data: Data([1]), contentType: "image/jpeg") { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)

        guard case let .failure(error)? = received else {
            return XCTFail("非 2xx 应失败: \(String(describing: received))")
        }
        XCTAssertEqual(error, .uploadFailed)
    }

    // MARK: - 确认契约

    func testCompleteUploadParsesAvatarResult() {
        StubURLProtocol.handler = { _ in .json(tspEnvelope(data: avatarResultPayload())) }
        let client = makeStubbedAvatarClient(networkManager: makeStubbedNetworkManager())

        let expectation = expectation(description: "complete")
        var received: Result<AvatarResult, AvatarUploadError>?
        client.completeUpload(uploadId: "upload-1") { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)

        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.url?.absoluteString, "https://sgw.test/api/mobile/account/v1/profile/avatar/upload-1/complete")
        XCTAssertEqual(request?.avatarTestHeader("Authorization"), "Bearer test-token")

        guard case let .success(avatar)? = received else {
            return XCTFail("确认应成功: \(String(describing: received))")
        }
        XCTAssertEqual(avatar.avatarUrl, "https://bucket.cos.example.com/images/sec-ciam/a.jpg")
        XCTAssertEqual(avatar.objectId, "upload-1")
        XCTAssertEqual(avatar.contentType, "image/jpeg")
        XCTAssertEqual(avatar.size, 2048)
    }

    func testCompleteUploadMapsBusinessErrors() {
        let cases: [(String, AvatarUploadError)] = [
            ("701110", .taskExpired),
            ("701111", .forbidden),
            ("701112", .confirmFailed(retryable: true))
        ]

        for (code, expected) in cases {
            StubURLProtocol.reset()
            StubURLProtocol.handler = { _ in .json(tspEnvelope(code: code)) }
            let client = makeStubbedAvatarClient(networkManager: makeStubbedNetworkManager())

            let expectation = expectation(description: code)
            var received: Result<AvatarResult, AvatarUploadError>?
            client.completeUpload(uploadId: "upload-1") { result in
                received = result
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5)

            XCTAssertEqual(received ?? .success(AvatarResult(avatarUrl: "", objectId: "", contentType: "", size: 0)), .failure(expected), "业务码 \(code)")
        }
    }

    func testCompleteUploadUnparsableResponseIsRetryable() {
        StubURLProtocol.handler = { _ in StubURLProtocol.StubResponse(status: 502, body: Data("bad gateway".utf8)) }
        let client = makeStubbedAvatarClient(networkManager: makeStubbedNetworkManager())

        let expectation = expectation(description: "502")
        var received: Result<AvatarResult, AvatarUploadError>?
        client.completeUpload(uploadId: "upload-1") { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(
            received ?? .success(AvatarResult(avatarUrl: "", objectId: "", contentType: "", size: 0)),
            .failure(.confirmFailed(retryable: true))
        )
    }

    // MARK: - 日志脱敏

    func testUploadUrlIsRedactedInLogs() {
        XCTAssertEqual(
            NetworkManager.redactedURL("https://bucket.cos.example.com/a.jpg?sign=secret&q=1"),
            "https://bucket.cos.example.com/a.jpg?***"
        )
    }
}
