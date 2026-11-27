//
//  ExploreWebPolicyTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import XCTest
@testable import iov

/// TC-012-5 / TC-012-6 / TC-012-9：H5/HTML 导航策略与只读文档构建。
final class ExploreWebPolicyTests: XCTestCase {

    func testH5RequiresHTTPSAndHost() throws {
        XCTAssertTrue(ExploreWebPolicy.isAllowedH5URL(try XCTUnwrap(URL(string: "https://example.com/a"))))
        XCTAssertFalse(ExploreWebPolicy.isAllowedH5URL(try XCTUnwrap(URL(string: "http://example.com/a"))))
        XCTAssertFalse(ExploreWebPolicy.isAllowedH5URL(try XCTUnwrap(URL(string: "https:///a"))))
    }

    func testH5NavigationBlocksNonHTTPS() throws {
        XCTAssertEqual(ExploreWebPolicy.h5NavigationDecision(for: try XCTUnwrap(URL(string: "https://example.com/a"))),
                       .allowInWebView)
        XCTAssertEqual(ExploreWebPolicy.h5NavigationDecision(for: try XCTUnwrap(URL(string: "http://example.com/a"))),
                       .block)
        XCTAssertEqual(ExploreWebPolicy.h5NavigationDecision(for: try XCTUnwrap(URL(string: "weixin://open"))),
                       .block)
    }

    func testArticleNavigationAllowsBlankAndOpensHTTPSExternally() throws {
        XCTAssertEqual(ExploreWebPolicy.articleNavigationDecision(for: try XCTUnwrap(URL(string: "about:blank"))),
                       .allowInWebView)
        XCTAssertEqual(ExploreWebPolicy.articleNavigationDecision(for: try XCTUnwrap(URL(string: "https://example.com"))),
                       .openExternally)
        XCTAssertEqual(ExploreWebPolicy.articleNavigationDecision(for: try XCTUnwrap(URL(string: "http://example.com"))),
                       .block)
        XCTAssertEqual(ExploreWebPolicy.articleNavigationDecision(for: try XCTUnwrap(URL(string: "javascript:alert(1)"))),
                       .block)
    }

    func testHTMLDocumentIsBodyOnlyAndKeepsCSPSafety() throws {
        let detail = makeArticleDetail(title: "<script>alert(1)</script>",
                                       summary: "A & B",
                                       cover: nil,
                                       images: [],
                                       authorName: "作者 <x>",
                                       displayAt: Date(timeIntervalSince1970: 0),
                                       body: .officialHTML("<p>正文</p>"))
        let html = try XCTUnwrap(ExploreArticleHTMLDocumentBuilder.makeDocument(detail))
        XCTAssertTrue(html.contains("<article><p>正文</p></article>"))
        XCTAssertTrue(html.contains("Content-Security-Policy"))
        XCTAssertFalse(html.contains("<h1>"), "标题改由原生顶部栏渲染")
        XCTAssertFalse(html.contains("<img"), "图集改由原生轮播渲染")
        XCTAssertFalse(html.contains("作者 &lt;x&gt;"), "作者改由原生行渲染")
        XCTAssertFalse(html.contains("A &amp; B"), "摘要不再进入正文文档")
    }

    func testArticleGalleryImagesFilterInvalidURLsAndFallBackToUsableCover() throws {
        let invalid = ExploreImageViewState(url: nil, width: nil, height: nil, mime: nil, size: nil)
        let first = ExploreImageViewState(url: try XCTUnwrap(URL(string: "https://example.com/1.png")),
                                         width: 800, height: 600, mime: nil, size: nil)
        let second = ExploreImageViewState(url: try XCTUnwrap(URL(string: "https://example.com/2.png")),
                                          width: 800, height: 600, mime: nil, size: nil)
        let cover = ExploreImageViewState(url: try XCTUnwrap(URL(string: "https://example.com/cover.png")),
                                         width: 640, height: 480, mime: nil, size: nil)

        let mixed = makeArticleDetail(cover: nil, images: [invalid, first, second])
        XCTAssertEqual(mixed.galleryImages.map(\.url?.lastPathComponent), ["1.png", "2.png"])

        let onlyInvalid = makeArticleDetail(cover: cover, images: [invalid])
        XCTAssertEqual(onlyInvalid.galleryImages.map(\.url?.lastPathComponent), ["cover.png"],
                       "全部不可用时退回兼容 cover")

        let empty = makeArticleDetail(cover: nil, images: [])
        XCTAssertTrue(empty.galleryImages.isEmpty)
    }

    private func makeArticleDetail(title: String? = "标题",
                                   summary: String? = nil,
                                   cover: ExploreImageViewState? = nil,
                                   images: [ExploreImageViewState] = [],
                                   authorName: String? = nil,
                                   displayAt: Date? = nil,
                                   body: ExploreArticleBody = .officialHTML("<p>正文</p>")) -> ExploreArticleDetailViewState {
        return ExploreArticleDetailViewState(articleId: "a1",
                                             revisionId: "r1",
                                             title: title,
                                             summary: summary,
                                             cover: cover,
                                             images: images,
                                             imageCount: images.count,
                                             imageLayout: nil,
                                             authorName: authorName,
                                             authorAvatarURL: nil,
                                             displayAt: displayAt,
                                             body: body)
    }

    func testHTMLDocumentIsNilForUGCReference() {
        let detail = ExploreArticleDetailViewState(
            articleId: "a1",
            revisionId: "r1",
            title: "标题",
            summary: nil,
            cover: nil,
            images: [],
            imageCount: 0,
            imageLayout: nil,
            authorName: nil,
            authorAvatarURL: nil,
            displayAt: nil,
            body: .ugcReference(sourceContentId: "c1", nativeRouteCode: "community.article")
        )
        XCTAssertNil(ExploreArticleHTMLDocumentBuilder.makeDocument(detail))
    }
}
