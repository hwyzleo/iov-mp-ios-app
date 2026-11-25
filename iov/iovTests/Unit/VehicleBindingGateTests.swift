//
//  VehicleBindingGateTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import XCTest
import Combine
import Alamofire
@testable import iov

/// TC-011-1 / TC-011-2：扫码前登录门禁与 qrToken 登录后续跑。
final class VehicleBindingGateTests: XCTestCase {

    private var gate: FakeLoginGate!
    private var model: VehicleModel!
    private var intent: VehicleIntent!
    private var routes: [String] = []
    private var routeSubscription: AnyCancellable?

    override func setUp() {
        super.setUp()
        AppGlobalState.shared.isMock = true
        // 测试隔离：确保没有残留 Keychain 会话（否则请求会先去刷新 Token）
        AuthEnvironment.shared.sessionRepository.clearSession()
        AppGlobalState.shared.refreshLoginStatus()
        StubURLProtocol.reset()
        StubURLProtocol.handler = { _ in .json(Self.tspEnvelope(data: Self.scanPayload())) }
        TspManager.networkManagerProvider = { makeStubbedNetworkManager() }

        gate = FakeLoginGate(isLoggedIn: false)
        model = VehicleModel()
        intent = VehicleIntent(model: model, loginGate: gate)
        routes = []
        routeSubscription = model.routerSubject.screen.sink { [weak self] screen in
            self?.routes.append(String(describing: screen))
        }
        // 建立页面上下文（未登录时不会有任何网络请求）
        intent.viewOnAppear()
        StubURLProtocol.reset()
        StubURLProtocol.handler = { _ in .json(Self.tspEnvelope(data: Self.scanPayload())) }
    }

    override func tearDown() {
        routeSubscription?.cancel()
        routeSubscription = nil
        TspManager.networkManagerProvider = { NetworkManager.shared }
        StubURLProtocol.reset()
        super.tearDown()
    }

    // MARK: - TC-011-1 门禁零请求

    func testTapScanWithoutLoginRoutesToLoginAndSendsNoRequest() {
        intent.onTapScan()

        XCTAssertEqual(routes, ["login"], "未登录必须走登录，而不是进入相机")
        XCTAssertEqual(model.loginHint, .loginRequired)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty, "门禁不得发任何请求")
        XCTAssertEqual(model.bindingOperationState, .idle)
    }

    func testTapScanWhenLoggedInKeepsExistingScanPath() {
        gate.setLoggedIn(true)
        routes = []

        intent.onTapScan()

        XCTAssertEqual(routes, ["scan"])
        XCTAssertNil(model.loginHint)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    // MARK: - TC-011-2 续跑

    func testScanResultWithoutLoginIsStoredAndNotSent() {
        intent.onScanResult(payload: "qr-token-1")

        XCTAssertEqual(routes, ["login"])
        XCTAssertTrue(StubURLProtocol.requests.isEmpty, "未登录时不得提交扫码请求")
    }

    func testLoginCompletedResumesStoredTokenExactlyOnce() {
        intent.onScanResult(payload: "qr-token-1")
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)

        gate.setLoggedIn(true)
        intent.onLoginCompleted()

        // Alamofire 的请求在自有队列上异步发出，需等待请求真正到达替身
        XCTAssertTrue(waitForCondition { self.scanRequests.count == 1 }, "登录后必须自动续跑一次")
        XCTAssertEqual(scanRequests.first?.httpMethod, "POST")
        XCTAssertEqual(scanRequests.first?.avatarTestJSONBody()?["qrToken"] as? String, "qr-token-1")

        // 一个 token 只续跑一次
        intent.onLoginCompleted()
        _ = waitForCondition(timeout: 0.4) { false }
        XCTAssertEqual(scanRequests.count, 1, "一个 token 只允许续跑一次")
    }

    func testLoginCompletedWithoutStoredTokenReopensCamera() {
        intent.onTapScan()          // 未登录点扫码 → 登录
        XCTAssertEqual(routes, ["login"])

        gate.setLoggedIn(true)
        intent.onLoginCompleted()

        XCTAssertEqual(routes, ["login", "scan"], "仅 pendingEntry 时登录后进入相机，不弹二次提示")
        // 仅进入相机，不得自动提交扫码请求
        _ = waitForCondition(timeout: 0.3) { false }
        XCTAssertTrue(scanRequests.isEmpty)
    }

    func testLoginStatePublisherDrivesResume() {
        intent.onScanResult(payload: "qr-token-2")

        gate.setLoggedIn(true)
        XCTAssertTrue(waitForCondition { self.scanRequests.count == 1 },
                      "订阅登录态变化后应自动续跑")
    }

    func testLoginCancelledDropsStoredTokenAndAsksRescan() {
        intent.onScanResult(payload: "qr-token-3")
        intent.onLoginCancelled()

        XCTAssertEqual(model.loginHint, .rescanRequired)
        gate.setLoggedIn(true)
        intent.onLoginCompleted()
        // 等待一个稳定的观察窗口，确认没有任何续跑请求发出
        _ = waitForCondition(timeout: 0.5) { false }
        XCTAssertTrue(scanRequests.isEmpty, "取消登录后不得再续跑旧二维码")
    }

    // MARK: - PendingQRTokenStore（内存 / TTL / 一次性）

    func testStoreKeepsLatestTokenOnlyAndTakeClears() {
        let store = PendingQRTokenStore(now: { Date(timeIntervalSince1970: 1_000) })
        store.store("token-a")
        store.store("token-b")
        XCTAssertEqual(store.take(now: Date(timeIntervalSince1970: 1_000)), "token-b")
        XCTAssertNil(store.take(now: Date(timeIntervalSince1970: 1_000)), "一个 token 只续跑一次")
        XCTAssertFalse(store.hasPending)
    }

    func testStoreRejectsEmptyToken() {
        let store = PendingQRTokenStore(now: { Date(timeIntervalSince1970: 1_000) })
        store.store("   ")
        XCTAssertNil(store.take(now: Date(timeIntervalSince1970: 1_000)))
    }

    func testStoreDropsTokenAfterTTL() {
        let start = Date(timeIntervalSince1970: 1_000)
        let store = PendingQRTokenStore(ttl: 120, now: { start })
        store.store("token-c", now: start)

        XCTAssertNil(store.take(now: start.addingTimeInterval(120)), "达到 TTL 即失效")
        XCTAssertFalse(store.hasPending)
    }

    func testInvalidatePreventsResume() {
        let start = Date(timeIntervalSince1970: 1_000)
        let store = PendingQRTokenStore(ttl: 120, now: { start })
        store.store("token-d", now: start)
        store.invalidate()
        XCTAssertNil(store.take(now: start))
        XCTAssertFalse(store.hasPending)
    }

    // MARK: - 等待工具

    private var scanRequests: [URLRequest] {
        StubURLProtocol.requests.filter { $0.url?.path.hasSuffix("/session/scan") == true }
    }

    /// 轮询等待条件成立（Alamofire 请求在自有队列异步发出，不能同步断言）
    @discardableResult
    private func waitForCondition(timeout: TimeInterval = 3,
                                 _ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }

    // MARK: - Fixtures

    static func scanPayload(claimed: Bool = true, state: String = "SCANNED") -> [String: Any] {
        [
            "sessionId": "S-1",
            "vin": "LSVAA123456789012",
            "state": state,
            "claimed": claimed
        ]
    }

    static func tspEnvelope(code: String = "000000", data: [String: Any]? = nil) -> Data {
        var payload: [String: Any] = ["code": code, "message": "ok", "ts": 1_700_000_000_000]
        if let data { payload["data"] = data }
        return try! JSONSerialization.data(withJSONObject: payload)
    }
}

// MARK: - 登录门禁替身

final class FakeLoginGate: LoginGateProviding {
    private let subject: CurrentValueSubject<Bool, Never>
    private var loggedIn: Bool

    init(isLoggedIn: Bool) {
        self.loggedIn = isLoggedIn
        self.subject = CurrentValueSubject(isLoggedIn)
    }

    var isLoggedIn: Bool { loggedIn }

    var loginState: AnyPublisher<Bool, Never> { subject.eraseToAnyPublisher() }

    /// 模拟登录成功 / 取消
    func setLoggedIn(_ value: Bool) {
        loggedIn = value
        subject.send(value)
    }
}
