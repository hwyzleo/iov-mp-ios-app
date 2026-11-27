//
//  AvatarTestSupport.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-003 on 2026/11/12.
//

import Foundation
import UIKit
import XCTest
import Alamofire
@testable import iov

// MARK: - URLProtocol 替身

/// 可控远程替身：记录请求并按 handler 返回响应（不依赖真实 CIAM/COS）
final class StubURLProtocol: URLProtocol {

    struct StubResponse {
        var status: Int
        var body: Data
        var headers: [String: String]

        init(status: Int, body: Data, headers: [String: String] = ["Content-Type": "application/json"]) {
            self.status = status
            self.body = body
            self.headers = headers
        }

        static func json(_ data: Data, status: Int = 200, headers: [String: String]? = nil) -> StubResponse {
            return StubResponse(status: status,
                                body: data,
                                headers: headers ?? ["Content-Type": "application/json"])
        }

        static func empty(status: Int = 200, headers: [String: String] = ["Content-Type": "application/json"]) -> StubResponse {
            return StubResponse(status: status, body: Data(), headers: headers)
        }
    }

    private static let lock = NSLock()
    private static var _handler: ((URLRequest) -> StubResponse)?
    private static var _requests: [URLRequest] = []

    static var handler: ((URLRequest) -> StubResponse)? {
        get {
            lock.lock(); defer { lock.unlock() }
            return _handler
        }
        set {
            lock.lock(); defer { lock.unlock() }
            _handler = newValue
        }
    }

    /// 已记录的请求（按到达顺序）
    static var requests: [URLRequest] {
        lock.lock(); defer { lock.unlock() }
        return _requests
    }

    static func reset() {
        lock.lock(); defer { lock.unlock() }
        _handler = nil
        _requests = []
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        StubURLProtocol.lock.lock()
        StubURLProtocol._requests.append(request)
        let handler = StubURLProtocol._handler
        StubURLProtocol.lock.unlock()

        let stub = handler?(request) ?? StubURLProtocol.StubResponse(status: 500, body: Data())
        let url = request.url ?? URL(string: "https://stub.invalid")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: stub.status,
            httpVersion: "HTTP/1.1",
            headerFields: stub.headers
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if !stub.body.isEmpty {
            client?.urlProtocol(self, didLoad: stub.body)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

// MARK: - 构造工具

func makeStubbedNetworkManager() -> NetworkManager {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    let session = Session(configuration: configuration)
    return NetworkManager(session: session)
}

func makeStubbedAvatarClient(
    networkManager: NetworkManager,
    now: @escaping () -> Date = Date.init
) -> AvatarRemoteAPIClient {
    return AvatarRemoteAPIClient(
        networkManager: networkManager,
        baseURL: { "https://sgw.test" },
        headers: { ["Authorization": "Bearer test-token", "X-Client-Id": "test-client"] },
        ensureSession: { completion in completion(.success(())) },
        now: now
    )
}

func tspEnvelope(code: String = "000000", data: [String: Any]? = nil) -> Data {
    var payload: [String: Any] = [
        "code": code,
        "message": code == "000000" ? "ok" : "error",
        "ts": 1700000000000,
        "timestamp": 1700000000000
    ]
    if let data = data {
        payload["data"] = data
    }
    return try! JSONSerialization.data(withJSONObject: payload)
}

func avatarTicketPayload(
    uploadId: String = "upload-1",
    uploadUrl: String = "https://bucket.cos.example.com/images/sec-ciam/a.jpg?sign=abc&q=1",
    httpMethod: String = "PUT",
    contentType: String = "image/jpeg",
    expiresAt: Int64? = nil
) -> [String: Any] {
    let expires = expiresAt ?? Int64(Date().addingTimeInterval(600).timeIntervalSince1970 * 1000)
    return [
        "uploadId": uploadId,
        "uploadUrl": uploadUrl,
        "httpMethod": httpMethod,
        "contentType": contentType,
        "expiresAt": expires
    ]
}

func avatarResultPayload(
    avatarUrl: String = "https://bucket.cos.example.com/images/sec-ciam/a.jpg",
    objectId: String = "upload-1",
    contentType: String = "image/jpeg",
    size: Int = 2048
) -> [String: Any] {
    return [
        "avatarUrl": avatarUrl,
        "objectId": objectId,
        "contentType": contentType,
        "size": size
    ]
}

// MARK: - 请求体读取

extension URLRequest {
    /// URLProtocol 中 `httpBody` 可能被转为 `httpBodyStream`
    var avatarTestBody: Data? {
        if let body = httpBody {
            return body
        }
        guard let stream = httpBodyStream else { return nil }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read <= 0 { break }
            data.append(buffer, count: read)
        }
        return data
    }

    func avatarTestJSONBody() -> [String: Any]? {
        guard let data = avatarTestBody else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    func avatarTestHeader(_ name: String) -> String? {
        return value(forHTTPHeaderField: name)
    }
}

// MARK: - 测试用图片

func makeTestImage(width: Int, height: Int) -> UIImage {
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1
    format.opaque = true
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
    return renderer.image { context in
        UIColor.green.setFill()
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        UIColor.red.setFill()
        context.fill(CGRect(x: width / 3, y: height / 3, width: width / 3, height: height / 3))
    }
}
