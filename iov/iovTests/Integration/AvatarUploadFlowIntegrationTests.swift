//
//  AvatarUploadFlowIntegrationTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-003 on 2026/11/12.
//

import XCTest
import UIKit
@testable import iov

/// 头像上传集成测试：Intent + AvatarUploadService + 真实请求层（URLProtocol 替身）
final class AvatarUploadFlowIntegrationTests: XCTestCase {

    private var originalAvatar: String?

    override func setUp() {
        super.setUp()
        originalAvatar = UserDefaults.standard.string(forKey: "userAvatar")
    }

    override func tearDown() {
        if let originalAvatar = originalAvatar {
            UserDefaults.standard.set(originalAvatar, forKey: "userAvatar")
        } else {
            UserDefaults.standard.removeObject(forKey: "userAvatar")
        }
        StubURLProtocol.reset()
        super.tearDown()
    }

    func testSuccessFlowUpdatesAvatarOnlyAfterConfirm() {
        let newAvatarUrl = "https://bucket.cos.example.com/images/sec-ciam/new.jpg"
        StubURLProtocol.handler = { request in
            if request.httpMethod == "PUT" {
                return .empty(status: 200)
            }
            if request.url?.path.hasSuffix("/complete") == true {
                return .json(tspEnvelope(data: avatarResultPayload(avatarUrl: newAvatarUrl)))
            }
            return .json(tspEnvelope(data: avatarTicketPayload()))
        }

        let (intent, model, expectation) = makeIntent()
        intent.onConfirmAvatarCrop(makeCropInput())
        wait(for: [expectation], timeout: 5)

        let requests = StubURLProtocol.requests
        XCTAssertEqual(requests.count, 3)
        guard requests.count == 3 else { return }
        XCTAssertEqual(requests[0].httpMethod, "POST")
        XCTAssertTrue(requests[0].url?.path.hasSuffix("/avatar/upload") == true)
        XCTAssertEqual(requests[1].httpMethod, "PUT")
        XCTAssertTrue(requests[2].url?.path.hasSuffix("/complete") == true)

        // 申请体 size 必须等于实际上传字节数（TC-003-2）
        let declaredSize = requests[0].avatarTestJSONBody()?["size"] as? Int
        let uploadedBytes = requests[1].avatarTestBody?.count
        XCTAssertNotNil(declaredSize)
        XCTAssertEqual(declaredSize, uploadedBytes)

        XCTAssertEqual(model.avatar, newAvatarUrl)
        XCTAssertEqual(model.updateAvatarCalls, [newAvatarUrl])
        XCTAssertEqual(model.avatarOperation, .idle)
        XCTAssertTrue(model.errorTexts.isEmpty)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "userAvatar"), newAvatarUrl)
    }

    func testConfirmFailureKeepsOldAvatar() {
        let oldAvatarUrl = "https://old.example.com/old.jpg"
        StubURLProtocol.handler = { request in
            if request.httpMethod == "PUT" {
                return .empty(status: 200)
            }
            if request.url?.path.hasSuffix("/complete") == true {
                return .json(tspEnvelope(code: "701112"))
            }
            return .json(tspEnvelope(data: avatarTicketPayload()))
        }

        let (intent, model, expectation) = makeIntent(oldAvatar: oldAvatarUrl)
        intent.onConfirmAvatarCrop(makeCropInput())
        wait(for: [expectation], timeout: 5)

        let completeRequests = StubURLProtocol.requests.filter { $0.url?.path.hasSuffix("/complete") == true }
        XCTAssertEqual(completeRequests.count, 2, "确认失败应自动重试一次")

        XCTAssertEqual(model.avatar, oldAvatarUrl, "失败不得覆盖旧头像")
        XCTAssertTrue(model.updateAvatarCalls.isEmpty)
        XCTAssertEqual(model.avatarOperation, .idle)
        XCTAssertFalse(model.errorTexts.isEmpty)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "userAvatar") == oldAvatarUrl, true)
    }

    func testDirectUploadFailureSkipsConfirmAndKeepsAvatar() {
        let oldAvatarUrl = "https://old.example.com/old.jpg"
        StubURLProtocol.handler = { request in
            if request.httpMethod == "PUT" {
                return .empty(status: 403)
            }
            if request.url?.path.hasSuffix("/complete") == true {
                return .json(tspEnvelope(data: avatarResultPayload()))
            }
            return .json(tspEnvelope(data: avatarTicketPayload()))
        }

        let (intent, model, expectation) = makeIntent(oldAvatar: oldAvatarUrl)
        intent.onConfirmAvatarCrop(makeCropInput())
        wait(for: [expectation], timeout: 5)

        let requests = StubURLProtocol.requests
        XCTAssertEqual(requests.filter { $0.url?.path.hasSuffix("/complete") == true }.count, 0)
        XCTAssertEqual(model.avatar, oldAvatarUrl)
        XCTAssertTrue(model.updateAvatarCalls.isEmpty)
        XCTAssertFalse(model.errorTexts.isEmpty)
    }

    func testTaskExpiredIsNotRetried() {
        StubURLProtocol.handler = { request in
            if request.httpMethod == "PUT" {
                return .empty(status: 200)
            }
            if request.url?.path.hasSuffix("/complete") == true {
                return .json(tspEnvelope(code: "701110"))
            }
            return .json(tspEnvelope(data: avatarTicketPayload()))
        }

        let (intent, model, expectation) = makeIntent()
        intent.onConfirmAvatarCrop(makeCropInput())
        wait(for: [expectation], timeout: 5)

        let completeRequests = StubURLProtocol.requests.filter { $0.url?.path.hasSuffix("/complete") == true }
        XCTAssertEqual(completeRequests.count, 1, "701110 不得自动重试")
        XCTAssertTrue(model.updateAvatarCalls.isEmpty)
        XCTAssertFalse(model.errorTexts.isEmpty)
    }

    // MARK: - Helpers

    private func makeCropInput() -> AvatarCropInput {
        let image = makeTestImage(width: 1200, height: 900)
        let scale = CropGeometry.minimumScale(imageSize: image.size, cropSide: 280)
        return AvatarCropInput(image: image, cropSide: 280, scale: scale, offset: .zero)
    }

    private func makeIntent(oldAvatar: String = "https://old.example.com/old.jpg") -> (MySettingProfileIntent, RecordingProfileModel, XCTestExpectation) {
        let model = RecordingProfileModel(avatar: oldAvatar)
        let service = AvatarUploadService(
            remote: makeStubbedAvatarClient(networkManager: makeStubbedNetworkManager()),
            retryDelay: 0
        )
        let intent = MySettingProfileIntent(model: model, avatarService: service)
        let expectation = expectation(description: "avatar settled")
        model.onSettled = { expectation.fulfill() }
        return (intent, model, expectation)
    }
}

// MARK: - Recording model

final class RecordingProfileModel: MySettingProfileModelActionProtocol, MySettingProfileModelRouterProtocol {

    var avatar: String
    var avatarOperation: MySettingProfileTypes.Model.AvatarOperation = .idle
    var avatarErrorMessage: String?
    var updateAvatarCalls: [String] = []
    var errorTexts: [String] = []
    var onSettled: (() -> Void)?

    init(avatar: String) {
        self.avatar = avatar
        UserDefaults.standard.set(avatar, forKey: "userAvatar")
    }

    func displayLoading() {}

    func displayProfile() {}

    func updateProfile(account: AccountInfo) {}

    func updateNickname(nickname: String) {}

    func updateAvatar(imageUrl: String) {
        avatar = imageUrl
        avatarOperation = .idle
        updateAvatarCalls.append(imageUrl)
        onSettled?()
    }

    func beginAvatarUpload() {
        avatarOperation = .uploading
        avatarErrorMessage = nil
    }

    func finishAvatarUpload(error: String?) {
        avatarOperation = .idle
        avatarErrorMessage = error
        onSettled?()
    }

    func displayError(text: String) {
        errorTexts.append(text)
    }

    func closeScreen() {}
}
