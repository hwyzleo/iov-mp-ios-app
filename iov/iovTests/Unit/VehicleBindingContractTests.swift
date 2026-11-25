//
//  VehicleBindingContractTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-010 on 2026/11/21.
//

import XCTest
@testable import iov

/// 客户端与 IOV-TSP-DSN-CR-017 C 端绑车接口的契约测试：
/// 字段解码、时间归一、缺失/未知值不猜测，以及“无关系查询接口”的显式降级。
final class VehicleBindingContractTests: XCTestCase {

    private let decoder = JSONDecoder()

    // MARK: - 扫码会话

    func testScanResultDecodesCamelCasePayloadAndNormalizesIsoTimestamp() throws {
        let json = """
        {
          "sessionId": "S-1",
          "vin": "LSVAA123456789012",
          "state": "SCANNED",
          "expiresAt": "2026-11-21T10:00:00.123456789Z",
          "claimed": true
        }
        """
        let result = try decoder.decode(ActivationScanResult.self, from: Data(json.utf8))
        XCTAssertEqual(result.sessionId, "S-1")
        XCTAssertEqual(result.vin, "LSVAA123456789012")
        XCTAssertEqual(ActivationSessionState(serverValue: result.state), .scanned)
        XCTAssertEqual(result.claimed, true)
        XCTAssertNotNil(result.expiresAt)
        // 精度归一为毫秒（纳秒截断，不四舍五入）
        XCTAssertEqual(result.expiresAt, 1_795_255_200_123)
    }

    func testScanResultRejectsPayloadWithoutSessionId() {
        let json = #"{"vin":"LSVAA123456789012","state":"SCANNED"}"#
        XCTAssertThrowsError(try decoder.decode(ActivationScanResult.self, from: Data(json.utf8)))
    }

    func testScanResultUnknownStateIsPreservedAsNilDomainValue() throws {
        let json = #"{"sessionId":"S-1","state":"FUTURE_STATE"}"#
        let result = try decoder.decode(ActivationScanResult.self, from: Data(json.utf8))
        XCTAssertNil(ActivationSessionState(serverValue: result.state))
        XCTAssertNil(result.vin)
        XCTAssertNil(result.expiresAt)
    }

    // MARK: - 确认绑定 / 操作查询

    func testConfirmSucceededDecodesRelationAndTimestamp() throws {
        let json = """
        {
          "operationId": "OP-1",
          "status": "SUCCEEDED",
          "reason": null,
          "relationId": "REL-1",
          "vin": "LSVAA123456789012",
          "completedAt": "2026-11-21T10:00:00Z"
        }
        """
        let result = try decoder.decode(ActivationConfirmResult.self, from: Data(json.utf8))
        XCTAssertEqual(result.operationId, "OP-1")
        XCTAssertEqual(ActivationBindingStatus(serverValue: result.status), .succeeded)
        XCTAssertEqual(result.relationId, "REL-1")
        XCTAssertNil(result.reason)
        XCTAssertEqual(result.completedAt, 1_795_255_200_000)
    }

    func testConfirmPendingWithoutCompletedAtDecodesAsPendingNotFailure() throws {
        let json = #"{"operationId":"OP-2","status":"PENDING","completedAt":null}"#
        let result = try decoder.decode(ActivationConfirmResult.self, from: Data(json.utf8))
        XCTAssertEqual(ActivationBindingStatus(serverValue: result.status), .pending)
        XCTAssertNil(result.completedAt)
        XCTAssertNil(result.reason)
    }

    func testConfirmFailedDecodesStableReason() throws {
        let json = #"{"operationId":"OP-3","status":"FAILED","reason":"RELATION_CONFLICT"}"#
        let result = try decoder.decode(ActivationConfirmResult.self, from: Data(json.utf8))
        XCTAssertEqual(ActivationBindingStatus(serverValue: result.status), .failed)
        XCTAssertEqual(VehicleBindingFailure.from(reason: result.reason), .relationConflict)
    }

    func testOperationQueryDecodesSessionAndStatus() throws {
        let json = """
        {
          "operationId": "OP-4",
          "status": "PENDING",
          "reason": "PENDING",
          "vin": "LSVAA123456789012",
          "sessionId": "S-1",
          "completedAt": null
        }
        """
        let result = try decoder.decode(ActivationOperationResult.self, from: Data(json.utf8))
        XCTAssertEqual(result.operationId, "OP-4")
        XCTAssertEqual(result.sessionId, "S-1")
        XCTAssertEqual(ActivationBindingStatus(serverValue: result.status), .pending)
        XCTAssertNil(result.completedAt)
    }

    // MARK: - VSO 车辆 VIN

    func testMyVehicleVoDecodesWithoutVinForBackwardCompatibility() throws {
        let json = #"{"id":"ORD-1","type":"ORDER","state":650,"displayName":"Model X"}"#
        let vo = try decoder.decode(MyVehicleVo.self, from: Data(json.utf8))
        XCTAssertNil(vo.vin)
    }

    func testMyVehicleVoDecodesOptionalVinWhenProvided() throws {
        let json = #"{"id":"ORD-1","type":"ORDER","state":650,"displayName":"Model X","vin":"LSVAA123456789012"}"#
        let vo = try decoder.decode(MyVehicleVo.self, from: Data(json.utf8))
        XCTAssertEqual(vo.vin, "LSVAA123456789012")
    }

    func testOrderListDecodesOptionalVinFromVso() throws {
        let withVin = #"{"orderNum":"ORD-1","orderState":650,"displayName":"Model X","vin":"LSVAA123456789012"}"#
        let decoded = try decoder.decode(VehicleSaleOrder.self, from: Data(withVin.utf8))
        XCTAssertEqual(decoded.vin, "LSVAA123456789012")

        let withoutVin = #"{"orderNum":"ORD-2","orderState":600,"displayName":"Model Y"}"#
        XCTAssertNil(try decoder.decode(VehicleSaleOrder.self, from: Data(withoutVin.utf8)).vin)
    }

    func testOrderDetailDecodesOptionalVinFromVso() throws {
        let withVin = #"{"orderNo":"ORD-1","orderState":650,"vin":"LSVAA123456789012"}"#
        let decoded = try decoder.decode(Order.self, from: Data(withVin.utf8))
        XCTAssertEqual(decoded.vin, "LSVAA123456789012")

        let withoutVin = #"{"orderNo":"ORD-2","orderState":600,"vin":null}"#
        XCTAssertNil(try decoder.decode(Order.self, from: Data(withoutVin.utf8)).vin)
    }

    // MARK: - 人车关系查询（IOV-TSP-DSN-CR-018）

    func testRelationQueryDecodesBoundPayload() throws {
        let json = """
        {
          "status": "BOUND",
          "vin": "LSVAA123456789012",
          "relationId": "REL-1",
          "role": "PRIMARY_USER",
          "boundAt": "2026-11-21T10:00:00.123Z"
        }
        """
        let result = try decoder.decode(UserVehicleRelationResult.self, from: Data(json.utf8))
        XCTAssertEqual(result.status, "BOUND")
        XCTAssertEqual(result.relationId, "REL-1")
        XCTAssertEqual(result.role, "PRIMARY_USER")
        XCTAssertEqual(result.boundAt, 1_795_255_200_123)
    }

    func testRelationQueryDecodesNotBoundPayloadWithNulls() throws {
        let json = #"{"status":"NOT_BOUND","vin":"LSVAA123456789012","relationId":null,"role":null,"boundAt":null}"#
        let result = try decoder.decode(UserVehicleRelationResult.self, from: Data(json.utf8))
        XCTAssertEqual(result.status, "NOT_BOUND")
        XCTAssertNil(result.relationId)
        XCTAssertNil(result.role)
        XCTAssertNil(result.boundAt)
    }

    func testRelationStatusMappingNeverTreatsUnknownAsUnbound() {
        XCTAssertEqual(
            RealVehicleBindingService.relationshipState(
                from: UserVehicleRelationResult(status: "BOUND", vin: nil, relationId: "REL-1", role: nil, boundAt: nil)
            ),
            .bound(relationId: "REL-1")
        )
        XCTAssertEqual(
            RealVehicleBindingService.relationshipState(
                from: UserVehicleRelationResult(status: "NOT_BOUND", vin: "LSVAA123456789012",
                                                relationId: nil, role: nil, boundAt: nil)
            ),
            .unboundForCurrentAccount
        )
        XCTAssertEqual(
            RealVehicleBindingService.relationshipState(
                from: UserVehicleRelationResult(status: "FUTURE_STATUS", vin: nil, relationId: nil,
                                                role: nil, boundAt: nil)
            ),
            .unknown(.invalidResponse)
        )
    }

    func testRelationQueryUsesNormalizedVinAndMapsBound() {
        var fetchedVin: String?
        let service = RealVehicleBindingService { vin, completion in
            fetchedVin = vin
            completion(.success(TspResponse(code: "000000", data: UserVehicleRelationResult(
                status: "BOUND", vin: vin, relationId: "REL-1", role: "PRIMARY_USER", boundAt: nil
            ))))
        }
        let context = VehiclePageContext(accountId: "acc-1", vehicleId: "ORD-1", vin: " lsvaa123456789012 ")
        var received: VehicleRelationshipState?
        service.queryRelationship(context: context) { received = $0 }
        XCTAssertEqual(fetchedVin, "LSVAA123456789012")
        XCTAssertEqual(received, .bound(relationId: "REL-1"))
    }

    func testRelationQueryNotBoundIsTheOnlyUnboundAuthority() {
        let service = RealVehicleBindingService { _, completion in
            completion(.success(TspResponse(code: "000000", data: UserVehicleRelationResult(
                status: "NOT_BOUND", vin: "LSVAA123456789012", relationId: nil, role: nil, boundAt: nil
            ))))
        }
        let context = VehiclePageContext(accountId: "acc-1", vehicleId: "ORD-1", vin: "LSVAA123456789012")
        var received: VehicleRelationshipState?
        service.queryRelationship(context: context) { received = $0 }
        XCTAssertEqual(received, .unboundForCurrentAccount)
    }

    func testRelationQuerySkipsNetworkForMissingOrInvalidVin() {
        var networkCalls = 0
        let service = RealVehicleBindingService { _, completion in
            networkCalls += 1
            completion(.failure(NSError(domain: "test", code: -1)))
        }
        var states: [VehicleRelationshipState] = []
        let nilVin = VehiclePageContext(accountId: "acc-1", vehicleId: "ORD-1", vin: nil)
        service.queryRelationship(context: nilVin) { states.append($0) }

        // 含 I，违反 ISO 3779，服务端会以 401112 拒绝
        let invalidVin = VehiclePageContext(accountId: "acc-1", vehicleId: "ORD-1", vin: "VIN00000000000001")
        service.queryRelationship(context: invalidVin) { states.append($0) }

        XCTAssertEqual(networkCalls, 0)
        XCTAssertEqual(states, [.unknown(.capabilityUnavailable), .unknown(.capabilityUnavailable)])
    }

    func testRelationQueryNetworkFailureStaysUnknown() {
        let service = RealVehicleBindingService { _, completion in
            completion(.failure(NSError(domain: "test", code: -1)))
        }
        let context = VehiclePageContext(accountId: "acc-1", vehicleId: "ORD-1", vin: "LSVAA123456789012")
        var received: VehicleRelationshipState?
        service.queryRelationship(context: context) { received = $0 }
        XCTAssertEqual(received, .unknown(.network))
        XCTAssertNotEqual(received, .unboundForCurrentAccount)
    }

    func testRelationQueryServerErrorStaysUnknown() {
        let service = RealVehicleBindingService { _, completion in
            completion(.success(TspResponse(code: "401112", data: nil)))
        }
        let context = VehiclePageContext(accountId: "acc-1", vehicleId: "ORD-1", vin: "LSVAA123456789012")
        var received: VehicleRelationshipState?
        service.queryRelationship(context: context) { received = $0 }
        XCTAssertEqual(received, .unknown(.invalidResponse))
    }

    // MARK: - 响应包络

    func testBindingErrorEnvelopeKeepsCodeAndMessage() throws {
        let json = """
        {"code":"401109","message":"该车辆已存在其他用户的主使用人关系","ts":1794550400123,"data":null}
        """
        let response = try decoder.decode(TspResponse<ActivationConfirmResult>.self, from: Data(json.utf8))
        XCTAssertFalse(response.isSuccess)
        XCTAssertEqual(VehicleBindingFailure.from(code: response.code, message: response.message), .relationConflict)
        XCTAssertNil(response.data)
    }
}

// MARK: - TC-011-7 五个接口的请求构造契约（StubURLProtocol）

/// 断言扫码 / 确认 / 取消 / 操作查询 / 关系查询的真实请求形态（method、path、query、body）。
final class VehicleBindingRequestContractTests: XCTestCase {

    private let context = VehiclePageContext(accountId: "acc-1",
                                            vehicleId: "ORD-1",
                                            vin: "LSVAA123456789012")

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
        StubURLProtocol.handler = { _ in .json(Self.envelope(data: ["sessionId": "S-1"])) }
        TspManager.networkManagerProvider = { makeStubbedNetworkManager() }
    }

    override func tearDown() {
        TspManager.networkManagerProvider = { NetworkManager.shared }
        StubURLProtocol.reset()
        super.tearDown()
    }

    func testScanRequestConstruction() {
        let service = RealVehicleBindingService()
        let expectation = expectation(description: "scan")
        service.scanActivationSession(qrToken: "qr-token-1") { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 5)

        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.url?.path, "/api/mobile/activation/v1/session/scan")
        XCTAssertEqual(request?.avatarTestJSONBody()?["qrToken"] as? String, "qr-token-1")
    }

    func testConfirmRequestConstruction() {
        let service = RealVehicleBindingService()
        let expectation = expectation(description: "confirm")
        service.confirmVehicleBinding(sessionId: "S-1", idempotencyKey: "KEY-1") { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 5)

        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.url?.path, "/api/mobile/activation/v1/binding/confirm")
        let body = request?.avatarTestJSONBody()
        XCTAssertEqual(body?["sessionId"] as? String, "S-1")
        XCTAssertEqual(body?["idempotencyKey"] as? String, "KEY-1")
    }

    func testCancelRequestConstructionEncodesSessionId() {
        let service = RealVehicleBindingService()
        let expectation = expectation(description: "cancel")
        service.cancelActivationSession(sessionId: "S 1/2") { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 5)

        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.url?.path, "/api/mobile/activation/v1/session/cancel")
        // sessionId 必须百分号编码后作为 query 传递（用 absoluteString 断言原始编码形态）
        let absolute = request?.url?.absoluteString ?? ""
        XCTAssertTrue(absolute.contains("sessionId=S%201%2F2"), "url=\(absolute)")
    }

    func testOperationQueryRequestConstruction() {
        let service = RealVehicleBindingService()
        let expectation = expectation(description: "operation")
        service.queryBindingOperation(operationId: "OP 1/2") { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 5)

        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertTrue((request?.url?.absoluteString ?? "").hasSuffix("/binding/operations/OP%201%2F2"),
                      "url=\(request?.url?.absoluteString ?? "")")
    }

    func testRelationQueryRequestConstruction() {
        let service = RealVehicleBindingService()
        let expectation = expectation(description: "relation")
        var state: VehicleRelationshipState?
        service.queryRelationship(context: context) { result in
            state = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)

        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertEqual(request?.url?.path, "/api/mobile/activation/v1/binding")
        XCTAssertEqual(request?.url?.query, "vin=LSVAA123456789012")
        XCTAssertNotNil(state)
    }

    func testSuccessEnvelopeWithoutDataIsInvalidResponse() {
        StubURLProtocol.reset()
        StubURLProtocol.handler = { _ in .json(Self.envelope(code: "000000", data: nil)) }
        let service = RealVehicleBindingService()
        let expectation = expectation(description: "missing data")
        var received: Result<ActivationScanResult, VehicleBindingFailure>?
        service.scanActivationSession(qrToken: "qr") { result in
            received = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)

        guard case let .failure(failure)? = received else {
            return XCTFail("缺 data 必须失败: \(String(describing: received))")
        }
        XCTAssertEqual(failure, .invalidResponse)
    }

    private static func envelope(code: String = "000000", data: [String: Any]?) -> Data {
        var payload: [String: Any] = ["code": code, "message": "ok", "ts": 1_700_000_000_000]
        if let data { payload["data"] = data }
        return try! JSONSerialization.data(withJSONObject: payload)
    }
}
