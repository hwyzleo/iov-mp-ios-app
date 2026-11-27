//
//  ExploreDecodingTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import XCTest
@testable import iov

/// TC-012-1：频道、页面、扁平组件配置与未知值的解码契约。
final class ExploreDecodingTests: XCTestCase {

    func testChannelsDecodeKeepsServerOrderAndSortNo() throws {
        let payload: [[String: Any]] = [
            exploreChannel("recommend", "推荐", sortNo: 2),
            exploreChannel("activity", "活动", sortNo: 1)
        ]
        let dtos = try decodeExplore([ExploreChannelDTO].self, payload)
        let channels = ExploreViewStateMapper.mapChannels(dtos)
        XCTAssertEqual(channels.map(\.code), ["recommend", "activity"], "必须保持服务端顺序，不按 sortNo 重排")
        XCTAssertEqual(channels.map(\.sortNo), [2, 1])
    }

    func testEmptyChannelsIsValid() throws {
        let dtos = try decodeExplore([ExploreChannelDTO].self, [])
        XCTAssertTrue(dtos.isEmpty)
    }

    func testPageDecodesFlatComponentConfiguration() throws {
        let payload = explorePage(
            channelCode: "recommend",
            components: [
                exploreBannerComponent("banner-1", sortNo: 1, title: "轮播", intervalSeconds: 7, items: []),
                exploreTopicComponent("topic-1", sortNo: 2, style: "HORIZONTAL_SCROLL", columns: 3, items: []),
                exploreFeedComponent("feed-1", sortNo: 3, title: "文章", items: [], hasMore: true, nextCursor: "c1")
            ]
        )
        let page = try mapExplorePage(payload)
        XCTAssertEqual(page.schemaVersion, 1)
        XCTAssertEqual(page.channelCode, "recommend")
        XCTAssertEqual(page.releaseId, "release-1")
        XCTAssertNotNil(page.publishedAt)
        XCTAssertEqual(page.components.map(\.id), ["banner-1", "topic-1", "feed-1"])

        guard case let .banner(banner) = page.components[0].content else {
            return XCTFail("expected banner")
        }
        XCTAssertEqual(banner.intervalSeconds, 7)
        XCTAssertEqual(page.components[0].title, "轮播")

        guard case let .topicGrid(grid) = page.components[1].content else {
            return XCTFail("expected topic grid")
        }
        XCTAssertEqual(grid.style, .horizontalScroll)

        guard case let .articleFeed(feed) = page.components[2].content else {
            return XCTFail("expected feed")
        }
        XCTAssertEqual(feed.hasMore, true)
        XCTAssertEqual(feed.nextCursor, "c1")
    }

    func testUnknownComponentAndItemTypesDoNotFailDecoding() throws {
        let unknownComponent: [String: Any] = [
            "type": "FUTURE_COMPONENT",
            "componentId": "future-1",
            "sortNo": 4,
            "items": [[
                "schemaVersion": 1,
                "itemType": "FUTURE_ITEM",
                "itemId": "x1"
            ]]
        ]
        let payload = explorePage(channelCode: "recommend",
                                  components: [unknownComponent])
        let page = try mapExplorePage(payload)
        XCTAssertEqual(page.components.count, 1)
        guard case .unknown = page.components[0].content else {
            return XCTFail("unknown component must be preserved as unknown")
        }
        XCTAssertFalse(page.hasRenderableComponent)
    }

    func testTargetsDecodeAllVariantsAndMalformedParamsDoNotFailPage() throws {
        let payload: [String: Any] = [
            "components": [[
                "type": "ARTICLE_FEED",
                "componentId": "feed-1",
                "sortNo": 1,
                "items": [
                    exploreArticleItem("a1", target: exploreTargetArticle("a1", "r1")),
                    exploreArticleItem("a2", target: exploreTargetTopic("t1", "tr1")),
                    exploreArticleItem("a3", target: exploreTargetH5("https://example.com/p/1")),
                    exploreArticleItem("a4", target: exploreTargetNative("native.code", ["orderNo": "O1"])),
                    exploreArticleItem("a5", target: ["type": "FUTURE_TARGET"]),
                    exploreArticleItem("a6", target: ["type": "NATIVE", "routeCode": "n1", "params": ["bad": 1]])
                ]
            ]],
            "channel": ["code": "recommend", "name": "推荐"],
            "releaseId": "release-1",
            "schemaVersion": 1
        ]
        let page = try mapExplorePage(payload)
        guard case let .articleFeed(feed) = page.components[0].content else {
            return XCTFail("expected feed")
        }
        XCTAssertEqual(feed.items.count, 6, "目标非法不得导致整页或条目丢失")
        XCTAssertEqual(feed.items[0].target, .article(ArticleRevisionRef(articleId: "a1", revisionId: "r1")))
        XCTAssertEqual(feed.items[1].target, .topic(TopicRevisionRef(topicId: "t1", revisionId: "tr1")))
        if case let .h5(url) = feed.items[2].target {
            XCTAssertEqual(url.absoluteString, "https://example.com/p/1")
        } else {
            XCTFail("expected h5")
        }
        XCTAssertEqual(feed.items[3].target, .native(routeCode: "native.code", params: ["orderNo": "O1"]))
        XCTAssertEqual(feed.items[4].target, .invalid)
        XCTAssertEqual(feed.items[5].target, .native(routeCode: "n1", params: [:]), "非法参数结构只让参数为空")
    }

    func testArticleDetailDecodesOfficialAndUGCFields() throws {
        let official = try decodeExplore(ExploreArticleDetailDTO.self,
                                         exploreArticleDetail(articleId: "a1",
                                                              revisionId: "r1",
                                                              sourceType: "OFFICIAL",
                                                              body: "<p>hello</p>"))
        XCTAssertEqual(official.articleId, "a1")
        XCTAssertEqual(official.revisionId, "r1")
        XCTAssertEqual(official.sourceType, "OFFICIAL")
        XCTAssertEqual(official.body, "<p>hello</p>")
        XCTAssertNil(official.nativeRouteCode)

        let ugc = try decodeExplore(ExploreArticleDetailDTO.self,
                                    exploreArticleDetail(articleId: "a2",
                                                         revisionId: "r2",
                                                         sourceType: "UGC_REFERENCE",
                                                         body: nil,
                                                         nativeRouteCode: "community.article"))
        XCTAssertEqual(ugc.sourceType, "UGC_REFERENCE")
        XCTAssertEqual(ugc.nativeRouteCode, "community.article")
    }

    func testTopicDetailAndFeedPageDecode() throws {
        let topic = try decodeExplore(ExploreTopicDetailDTO.self,
                                      exploreTopicDetail(items: [exploreArticleItem("a1")],
                                                         hasMore: true,
                                                         nextCursor: "cur"))
        XCTAssertEqual(topic.topicId, "t1")
        XCTAssertEqual(topic.items?.count, 1)
        XCTAssertEqual(topic.hasMore, true)
        XCTAssertEqual(topic.nextCursor, "cur")

        let feed = try decodeExplore(ExploreFeedPageDTO.self,
                                     exploreFeedPage(items: [exploreArticleItem("a2")],
                                                     hasMore: false))
        XCTAssertEqual(feed.releaseId, "release-1")
        XCTAssertEqual(feed.componentId, "feed-1")
        XCTAssertEqual(feed.items?.count, 1)
    }

    func testImageDecodeAcceptsMissingOrNegativeMetadata() throws {
        let dto = try decodeExplore(ExploreImageDTO.self,
                                    ["url": "not a url", "width": -1, "height": 0])
        XCTAssertEqual(dto.url, "not a url")
        XCTAssertEqual(dto.width, -1)
        XCTAssertEqual(dto.height, 0)
    }

    func testTopicDetailDecodesDetailImageFieldsAndKeepsNilVersusEmpty() throws {
        let withImages = try decodeExplore(ExploreTopicDetailDTO.self,
                                           exploreTopicDetail(images: [exploreImage("https://example.com/detail.png",
                                                                                    width: 1600,
                                                                                    height: 900)],
                                                              imageCount: 1,
                                                              imageLayout: "SINGLE",
                                                              items: []))
        XCTAssertEqual(withImages.images?.count, 1)
        XCTAssertEqual(withImages.images?.first?.url, "https://example.com/detail.png")
        XCTAssertEqual(withImages.imageCount, 1)
        XCTAssertEqual(withImages.imageLayout, "SINGLE")

        let empty = try decodeExplore(ExploreTopicDetailDTO.self,
                                      exploreTopicDetail(images: [],
                                                         imageCount: 0,
                                                         imageLayout: "SINGLE",
                                                         items: []))
        XCTAssertNotNil(empty.images, "显式空数组必须与字段缺失区分")
        XCTAssertEqual(empty.images?.count, 0)

        let legacy = try decodeExplore(ExploreTopicDetailDTO.self,
                                       exploreTopicDetail(items: []))
        XCTAssertNil(legacy.images, "旧服务字段缺失必须为 nil")
        XCTAssertNil(legacy.imageCount)
        XCTAssertNil(legacy.imageLayout)
    }

    func testDisplayTimestampsUseSharedFlexibleParser() throws {
        let iso = try decodeExplore(ExploreItemDTO.self,
                                    exploreArticleItem("a1", displayAt: "2026-11-26T10:00:00.123456789Z"))
        XCTAssertEqual(ExploreViewStateMapper.parseDate(iso.displayAt)?.timeIntervalSince1970 ?? 0,
                       1_795_687_200.123, accuracy: 0.001)

        let epoch = try decodeExplore(ExploreItemDTO.self,
                                      exploreArticleItem("a2", displayAt: "1795696800000"))
        XCTAssertNotNil(ExploreViewStateMapper.parseDate(epoch.displayAt))
    }
}
