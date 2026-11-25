//
//  BindingErrorClassifierTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import XCTest
@testable import iov

/// TC-011-6：错误语义分层（传输 / 解码 / 认证 / 网关卡）与统一会话失效触发。
final class BindingErrorClassifierTests: XCTestCase {

    // MARK: - Error 分类

    func testTransportErrorMapsToNetwork() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        XCTAssertEqual(BindingErrorClassifier.classify(error: error), .network)
        XCTAssertEqual(BindingErrorClassifier.classify(error: URLError(.networkConnectionLost)), .network)
    }

    func testDecodeErrorMapsToInvalidResponseNotNetwork() {
        let error = NSError(domain: "NetworkAPIError", code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Can not parse data"])
        XCTAssertEqual(BindingErrorClassifier.classify(error: error), .invalidResponse)
        XCTAssertNotEqual(BindingErrorClassifier.classify(error: error), .network)
    }

    func testDomainFailurePassesThroughUnchanged() {
        XCTAssertEqual(BindingErrorClassifier.classify(error: VehicleBindingFailure.sessionExpired),
                       .sessionExpired)
    }

    /// 方案 B 未实现：无状态码时 HTTP 401 空体落 `.invalidResponse`，不猜测为认证类
    func testHttp401WithoutStatusCodeFallsBackToInvalidResponse() {
        let error = NSError(domain: "NetworkAPIError", code: 0)
        XCTAssertEqual(BindingErrorClassifier.classify(error: error, statusCode: nil), .invalidResponse)
        // 若将来接入带状态码的增量方法，401 可识别为认证被拒（方案 B 预留）
        XCTAssertEqual(BindingErrorClassifier.classify(error: error, statusCode: 401), .authenticationRejected)
        XCTAssertEqual(BindingErrorClassifier.classify(error: error, statusCode: 403), .forbidden)
    }

    // MARK: - 包络业务码

    func testAuthenticationServerCodesAreLayered() {
        XCTAssertEqual(BindingErrorClassifier.classify(code: "701304"), .authenticationSessionExpired)
        XCTAssertEqual(BindingErrorClassifier.classify(code: "701403"), .authenticationRejected)
        XCTAssertTrue(BindingErrorClassifier.classify(code: "701304").isAuthenticationFailure)
    }

    func testGatewayCodesAreMappedByBlk9() {
        XCTAssertEqual(BindingErrorClassifier.classify(code: "SGW-401001"), .authenticationSessionExpired)
        XCTAssertEqual(BindingErrorClassifier.classify(code: "sgw-401001"), .authenticationSessionExpired)
        XCTAssertEqual(BindingErrorClassifier.classify(code: " SGW-403001 "), .forbidden)
        XCTAssertEqual(BindingErrorClassifier.classify(code: "SGW-404001"), .invalidResponse)
    }

    func testGatewayCodeInsideMessageIsAlsoRecognized() {
        let failure = BindingErrorClassifier.classify(code: "", message: "SGW-403001 forbidden")
        XCTAssertEqual(failure, .forbidden)
    }

    func testBindingCodesKeepExistingSemantics() {
        let expected: [String: VehicleBindingFailure] = [
            "401101": .sessionInvalid,
            "401102": .sessionExpired,
            "401103": .sessionCancelled,
            "401104": .sessionClaimed,
            "401105": .vehicleNotFound,
            "401106": .eligibilityRejected,
            "401107": .eligibilityUndetermined,
            "401108": .dependencyUnavailable,
            "401109": .relationConflict,
            "401110": .idempotencyConflict,
            "401111": .agreementNotAccepted,
            "401112": .invalidRequest
        ]
        for (code, failure) in expected {
            XCTAssertEqual(BindingErrorClassifier.classify(code: code), failure, "code=\(code)")
        }
    }

    func testUnknownCodeKeepsServerMessage() {
        XCTAssertEqual(BindingErrorClassifier.classify(code: "401199", message: "服务繁忙"),
                       .server(message: "服务繁忙"))
        XCTAssertEqual(BindingErrorClassifier.classify(code: "401199"), .unknown)
        XCTAssertEqual(BindingErrorClassifier.classify(code: nil, message: "boom"), .server(message: "boom"))
        XCTAssertEqual(BindingErrorClassifier.classify(code: nil, message: nil), .unknown)
    }

    // MARK: - 关系查询的认证维度真实赋值

    func testRelationshipQueryAuthenticationFailureIsAssigned() {
        let service = RealVehicleBindingService { _, completion in
            completion(.success(TspResponse(code: "701403", data: nil)))
        }
        let context = VehiclePageContext(accountId: "acc-1", vehicleId: "ORD-1", vin: "LSVAA123456789012")
        var received: VehicleRelationshipState?
        service.queryRelationship(context: context) { received = $0 }
        XCTAssertEqual(received, .unknown(.authenticationRejected))
    }

    func testRelationshipQueryInvalidResponseAndForbidden() {
        let invalid = RealVehicleBindingService { _, completion in
            completion(.success(TspResponse(code: "SGW-404001", data: nil)))
        }
        let forbidden = RealVehicleBindingService { _, completion in
            completion(.success(TspResponse(code: "SGW-403001", data: nil)))
        }
        let context = VehiclePageContext(accountId: "acc-1", vehicleId: "ORD-1", vin: "LSVAA123456789012")
        var states: [VehicleRelationshipState] = []
        invalid.queryRelationship(context: context) { states.append($0) }
        forbidden.queryRelationship(context: context) { states.append($0) }
        XCTAssertEqual(states, [.unknown(.invalidResponse), .unknown(.forbidden)])
    }

    func testRelationshipQueryDecodeFailureIsNotNetwork() {
        let service = RealVehicleBindingService { _, completion in
            completion(.failure(NSError(domain: "NetworkAPIError", code: 0)))
        }
        let context = VehiclePageContext(accountId: "acc-1", vehicleId: "ORD-1", vin: "LSVAA123456789012")
        var received: VehicleRelationshipState?
        service.queryRelationship(context: context) { received = $0 }
        XCTAssertEqual(received, .unknown(.invalidResponse))
    }

    // MARK: - 认证失败触发统一会话失效（协调器侧）

    func testAuthenticationFailureTriggersSessionExpiryOnceAndStopsRecovery() {
        let service = StubBindingService()
        let poller = BindingResultPoller(config: .init(delays: [0.01], maxAttempts: 3, maxTotalDuration: 60),
                                        scheduler: ManualPollerScheduler())
        var expiredCount = 0
        let coordinator = VehicleBindingCoordinator(service: service,
                                                   idempotencyKeyGenerator: { "KEY-1" },
                                                   poller: poller,
                                                   sessionExpiryHandler: { expiredCount += 1 })
        var operations: [VehicleBindingOperationState] = []
        coordinator.onOperation = { _, state in operations.append(state) }
        coordinator.start(context: VehiclePageContext(accountId: "acc-1", vehicleId: "order-1",
                                                     vin: "LSVAA123456789012"))
        coordinator.beginScan(qrToken: "qr")
        service.scanCalls[0].completion(.success(scanResult()))

        coordinator.confirm()
        service.confirmCalls[0].completion(.failure(.authenticationSessionExpired))

        XCTAssertEqual(expiredCount, 1, "认证失效必须触发一次统一会话失效清理")
        XCTAssertEqual(operations.last, .failed(.authenticationSessionExpired))
        XCTAssertFalse(poller.isRunning, "认证失败不得继续自动恢复")
    }

    // MARK: - Fixtures

    private func scanResult() -> ActivationScanResult {
        ActivationScanResult(sessionId: "S-1", vin: "LSVAA123456789012",
                             state: "SCANNED", expiresAt: nil, claimed: true)
    }
}
