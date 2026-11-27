//
//  ExploreTargetResolverTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import XCTest
@testable import iov

/// TC-012-5：目标矩阵与默认拒绝。
final class ExploreTargetResolverTests: XCTestCase {

    private let resolver = ExploreTargetResolver()

    func testArticleAndTopicRequireBothIdentifiers() {
        let article = ArticleRevisionRef(articleId: "a1", revisionId: "r1")
        XCTAssertEqual(resolver.resolve(.article(article)), .success(.article(article)))

        let emptyArticle = ArticleRevisionRef(articleId: " ", revisionId: "r1")
        XCTAssertEqual(resolver.resolve(.article(emptyArticle)), .failure(.unavailable))

        let topic = TopicRevisionRef(topicId: "t1", revisionId: "tr1")
        XCTAssertEqual(resolver.resolve(.topic(topic)), .success(.topic(topic)))
        XCTAssertEqual(resolver.resolve(.topic(TopicRevisionRef(topicId: "t1", revisionId: ""))),
                       .failure(.unavailable))
    }

    func testH5OnlyAcceptsAbsoluteHTTPSWithoutCredentials() throws {
        let https = try XCTUnwrap(URL(string: "https://example.com/path"))
        guard case let .success(.web(url)) = resolver.resolve(.h5(https)) else {
            return XCTFail("expected web route")
        }
        XCTAssertEqual(url, https)

        let uppercaseScheme = try XCTUnwrap(URL(string: "HTTPS://example.com/path"))
        guard case .success(.web) = resolver.resolve(.h5(uppercaseScheme)) else {
            return XCTFail("uppercase HTTPS scheme must be accepted")
        }

        for raw in ["http://example.com", "file:///tmp/a", "tel:123", "https:///path", "https://user:pass@example.com"] {
            let url = try XCTUnwrap(URL(string: raw))
            XCTAssertEqual(resolver.resolve(.h5(url)), .failure(.insecureURL), raw)
        }
    }

    func testInvalidTargetIsRejected() {
        XCTAssertEqual(resolver.resolve(.invalid), .failure(.unavailable))
    }

    func testNativeTargetsAreRejectedByProductionRegistry() {
        XCTAssertTrue(ExploreNativeRouteRegistry.production.isEmpty)
        XCTAssertEqual(resolver.resolve(.native(routeCode: "order.detail", params: ["orderNo": "O1"])),
                       .failure(.unsupportedNativeRoute))
    }

    func testRegisteredNativeRouteValidatesAllowedKeysAndRequiredValues() {
        let registration = ExploreNativeRouteRegistration(routeCode: "order.detail",
                                                         allowedParamKeys: ["orderNo"]) { params in
            guard let orderNo = params["orderNo"], !orderNo.isEmpty else { return nil }
            return .orderDetail(orderNo: orderNo)
        }
        let registry = ExploreNativeRouteRegistry(registrations: [registration])
        let customResolver = ExploreTargetResolver(nativeRegistry: registry)

        XCTAssertEqual(customResolver.resolve(.native(routeCode: "ORDER.DETAIL", params: ["orderNo": "O1"])),
                       .success(.native(.orderDetail(orderNo: "O1"))))
        XCTAssertEqual(customResolver.resolve(.native(routeCode: "order.detail", params: ["vin": "V1"])),
                       .failure(.invalidNativeParameters))
        XCTAssertEqual(customResolver.resolve(.native(routeCode: "order.detail", params: [:])),
                       .failure(.invalidNativeParameters))
        XCTAssertEqual(customResolver.resolve(.native(routeCode: "unknown", params: [:])),
                       .failure(.unsupportedNativeRoute))
    }
}
