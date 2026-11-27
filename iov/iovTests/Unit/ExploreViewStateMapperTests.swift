//
//  ExploreViewStateMapperTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import XCTest
@testable import iov

/// TC-012-1 / TC-012-2 / TC-012-3 / TC-012-4：排序、回退、媒体布局与可选字段。
final class ExploreViewStateMapperTests: XCTestCase {

    // MARK: - 排序与空态

    func testComponentsSortBySortNoAndKeepStableOrderForTies() throws {
        let payload = explorePage(channelCode: "recommend", components: [
            exploreFeedComponent("feed-b", sortNo: 2, items: []),
            exploreBannerComponent("banner-a", sortNo: 1, items: []),
            exploreFeedComponent("feed-c", sortNo: 2, items: [])
        ])
        let page = try mapExplorePage(payload)
        XCTAssertEqual(page.components.map(\.id), ["banner-a", "feed-b", "feed-c"])
    }

    func testMissingComponentIdIsSkipped() throws {
        let payload = explorePage(channelCode: "recommend", components: [
            ["type": "ARTICLE_FEED", "sortNo": 1, "items": []],
            exploreFeedComponent("feed-1", sortNo: 2, items: [])
        ])
        let page = try mapExplorePage(payload)
        XCTAssertEqual(page.components.map(\.id), ["feed-1"])
    }

    func testUnsupportedSchemaVersionAndMissingRequiredFieldsFail() throws {
        let dto = try decodeExplore(ExplorePageDTO.self,
                                    explorePage(channelCode: "recommend",
                                                schemaVersion: 2,
                                                components: []))
        guard case let .failure(failure) = ExploreViewStateMapper.mapPage(dto) else {
            return XCTFail("expected failure")
        }
        XCTAssertEqual(failure, .unsupportedSchemaVersion(2))

        let missing = try decodeExplore(ExplorePageDTO.self,
                                        ["schemaVersion": 1,
                                         "channel": ["code": "recommend"],
                                         "components": []])
        guard case let .failure(missingFailure) = ExploreViewStateMapper.mapPage(missing) else {
            return XCTFail("expected failure")
        }
        XCTAssertEqual(missingFailure, .invalidResponse)
    }

    // MARK: - Banner

    func testBannerIntervalFallsBackToFiveSeconds() throws {
        func interval(_ raw: Int?) throws -> Int {
            let payload = explorePage(channelCode: "recommend",
                                      components: [exploreBannerComponent("b1",
                                                                          intervalSeconds: raw,
                                                                          items: [])])
            let page = try mapExplorePage(payload)
            guard case let .banner(banner) = page.components[0].content else {
                throw ExploreFailure.invalidResponse
            }
            return banner.intervalSeconds
        }
        XCTAssertEqual(try interval(nil), 5)
        XCTAssertEqual(try interval(2), 5)
        XCTAssertEqual(try interval(11), 5)
        XCTAssertEqual(try interval(3), 3)
        XCTAssertEqual(try interval(10), 10)
    }

    func testEmptyBannerItemsProduceEmptyComponentContent() throws {
        let payload = explorePage(channelCode: "recommend",
                                  components: [exploreBannerComponent("b1", items: [])])
        let page = try mapExplorePage(payload)
        guard case let .banner(banner) = page.components[0].content else {
            return XCTFail("expected banner")
        }
        XCTAssertTrue(banner.items.isEmpty)
    }

    // MARK: - 专题样式

    func testTopicGridStylesAndColumnFallbacks() throws {
        func grid(style: String?, columns: Int?) throws -> ExploreTopicGridStyle {
            let type = style ?? "ADAPTIVE_GRID"
            let payload = explorePage(channelCode: "recommend",
                                      components: [exploreTopicComponent("t1",
                                                                          style: style,
                                                                          columns: columns,
                                                                          items: [])])
            let page = try mapExplorePage(payload)
            guard case let .topicGrid(grid) = page.components[0].content else {
                throw ExploreFailure.invalidResponse
            }
            XCTAssertNotNil(type)
            return grid.style
        }

        XCTAssertEqual(try grid(style: nil, columns: nil), .adaptiveGrid(columns: 4))
        XCTAssertEqual(try grid(style: "ADAPTIVE_GRID", columns: 2), .adaptiveGrid(columns: 2))
        XCTAssertEqual(try grid(style: "ADAPTIVE_GRID", columns: 3), .adaptiveGrid(columns: 3))
        XCTAssertEqual(try grid(style: "ADAPTIVE_GRID", columns: 4), .adaptiveGrid(columns: 4))
        XCTAssertEqual(try grid(style: "ADAPTIVE_GRID", columns: 5), .adaptiveGrid(columns: 4))
        XCTAssertEqual(try grid(style: "HORIZONTAL_SCROLL", columns: 2), .horizontalScroll)
        XCTAssertEqual(try grid(style: "IMAGE_TEXT_LIST", columns: 3), .imageTextList)
        XCTAssertEqual(try grid(style: "FUTURE_STYLE", columns: 3), .adaptiveGrid(columns: 4))
    }

    func testUnknownItemTypesAreSkippedInsideKnownComponents() throws {
        let unknownItem: [String: Any] = [
            "schemaVersion": 1,
            "itemType": "FUTURE_ITEM",
            "itemId": "x"
        ]
        let payload = explorePage(channelCode: "recommend", components: [
            exploreBannerComponent("b1", items: [unknownItem, exploreBannerItem("b1")]),
            exploreTopicComponent("t1", items: [unknownItem, exploreTopicItem("t1")]),
            exploreFeedComponent("f1", items: [unknownItem, exploreArticleItem("a1")])
        ])
        let page = try mapExplorePage(payload)
        for component in page.components {
            switch component.content {
            case let .banner(banner):
                XCTAssertEqual(banner.items.map(\.id), ["b1"])
            case let .topicGrid(grid):
                XCTAssertEqual(grid.items.map(\.id), ["t1"])
            case let .articleFeed(feed):
                XCTAssertEqual(feed.items.map(\.id), ["a1"])
            case .unknown:
                XCTFail("unexpected unknown")
            }
        }
    }

    // MARK: - 图片布局

    func testResolveImageLayoutUsesDeclaredOnlyWhenCompatible() {
        XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: "SINGLE", count: 1), .single)
        XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: "TWO_COLUMNS", count: 2), .twoColumns)
        XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: "ONE_LARGE_TWO_SMALL", count: 3), .oneLargeTwoSmall)
        XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: "TWO_BY_TWO", count: 4), .twoByTwo)
        XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: "THREE_COLUMNS", count: 6), .threeColumns)
        XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: "NINE_GRID_WITH_COUNT", count: 12), .nineGridWithCount)
        XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: "NINE_GRID_WITH_COUNT", count: 9), .nineGridWithCount)
        XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: "SINGLE", count: 4), .twoByTwo)
        XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: "FUTURE", count: 4), .twoByTwo)
        XCTAssertNil(ExploreViewStateMapper.resolveImageLayout(declared: "SINGLE", count: 0))
    }

    func testResolveImageLayoutCoversAllCounts() {
        let expected: [Int: ExploreImageLayout] = [
            1: .single,
            2: .twoColumns,
            3: .oneLargeTwoSmall,
            4: .twoByTwo,
            5: .threeColumns,
            6: .threeColumns,
            7: .threeColumns,
            8: .threeColumns,
            9: .threeColumns,
            10: .nineGridWithCount,
            12: .nineGridWithCount
        ]
        for (count, layout) in expected {
            XCTAssertEqual(ExploreViewStateMapper.resolveImageLayout(declared: nil, count: count), layout, "count=\(count)")
        }
    }

    func testInvalidImageURLAndDimensionsBecomeUnavailable() throws {
        let payload = explorePage(channelCode: "recommend", components: [
            exploreFeedComponent("f1", items: [
                exploreArticleItem("a1",
                                   images: [exploreImage("not a url", width: 0, height: -1)],
                                   imageCount: 1)
            ])
        ])
        let page = try mapExplorePage(payload)
        guard case let .articleFeed(feed) = page.components[0].content else {
            return XCTFail("expected feed")
        }
        let image = try XCTUnwrap(feed.items[0].images.first)
        XCTAssertNil(image.url)
        XCTAssertNil(image.width)
        XCTAssertNil(image.height)
        XCTAssertFalse(image.isAvailable)
        XCTAssertEqual(feed.items[0].imageLayout, .single)
    }

    func testOverNineImagesKeepCountAndNineGridLayout() throws {
        let images = (1...12).map { exploreImage("https://example.com/\($0).png") }
        let payload = explorePage(channelCode: "recommend", components: [
            exploreFeedComponent("f1", items: [
                exploreArticleItem("a1", images: images, imageCount: 12)
            ])
        ])
        let page = try mapExplorePage(payload)
        guard case let .articleFeed(feed) = page.components[0].content else {
            return XCTFail("expected feed")
        }
        XCTAssertEqual(feed.items[0].imageCount, 12)
        XCTAssertEqual(feed.items[0].imageLayout, .nineGridWithCount)
        XCTAssertEqual(feed.items[0].images.count, 12)
    }

    func testZeroImagesOmitLayoutAndOptionalFieldsAreNil() throws {
        let payload = explorePage(channelCode: "recommend", components: [
            exploreFeedComponent("f1", items: [
                exploreArticleItem("a1",
                                   title: " ",
                                   summary: nil,
                                   images: [],
                                   imageCount: 0,
                                   authorName: nil,
                                   displayAt: nil)
            ])
        ])
        let page = try mapExplorePage(payload)
        guard case let .articleFeed(feed) = page.components[0].content else {
            return XCTFail("expected feed")
        }
        XCTAssertNil(feed.items[0].title)
        XCTAssertNil(feed.items[0].summary)
        XCTAssertNil(feed.items[0].authorName)
        XCTAssertNil(feed.items[0].displayAt)
        XCTAssertNil(feed.items[0].imageLayout)
    }

    // MARK: - 详情

    func testArticleDetailOfficialAndUGCMapping() throws {
        let officialDTO = try decodeExplore(ExploreArticleDetailDTO.self,
                                            exploreArticleDetail(articleId: "a1",
                                                                 revisionId: "r1",
                                                                 sourceType: "OFFICIAL",
                                                                 body: "<p>hello</p>"))
        let official = try XCTUnwrap(try? ExploreViewStateMapper.mapArticleDetail(officialDTO,
                                                                                 expectedArticleId: "a1",
                                                                                 expectedRevisionId: "r1").get())
        XCTAssertEqual(official.body, .officialHTML("<p>hello</p>"))

        let ugcDTO = try decodeExplore(ExploreArticleDetailDTO.self,
                                       exploreArticleDetail(articleId: "a2",
                                                            revisionId: "r2",
                                                            sourceType: "UGC_REFERENCE",
                                                            body: nil,
                                                            nativeRouteCode: "community.article"))
        let ugc = try XCTUnwrap(try? ExploreViewStateMapper.mapArticleDetail(ugcDTO,
                                                                            expectedArticleId: "a2",
                                                                            expectedRevisionId: "r2").get())
        XCTAssertEqual(ugc.body, .ugcReference(sourceContentId: nil, nativeRouteCode: "community.article"))

        let unknownDTO = try decodeExplore(ExploreArticleDetailDTO.self,
                                           exploreArticleDetail(articleId: "a3",
                                                                revisionId: "r3",
                                                                sourceType: "FUTURE"))
        if case let .failure(failure) = ExploreViewStateMapper.mapArticleDetail(unknownDTO,
                                                                                expectedArticleId: "a3",
                                                                                expectedRevisionId: "r3") {
            XCTAssertEqual(failure, .contentUnavailable)
        } else {
            XCTFail("unknown sourceType must not be guessed")
        }
    }

    func testArticleDetailOfficialWithoutBodyIsUnavailable() throws {
        let dto = try decodeExplore(ExploreArticleDetailDTO.self,
                                    exploreArticleDetail(articleId: "a1",
                                                         revisionId: "r1",
                                                         body: " "))
        if case let .failure(failure) = ExploreViewStateMapper.mapArticleDetail(dto,
                                                                                expectedArticleId: "a1",
                                                                                expectedRevisionId: "r1") {
            XCTAssertEqual(failure, .contentUnavailable)
        } else {
            XCTFail("empty body must be unavailable")
        }
    }

    func testTopicDetailHasMoreRequiresCursorAndIdsMatch() throws {
        let dto = try decodeExplore(ExploreTopicDetailDTO.self,
                                    exploreTopicDetail(items: [exploreArticleItem("a1")],
                                                       hasMore: true,
                                                       nextCursor: nil))
        let topic = try XCTUnwrap(try? ExploreViewStateMapper.mapTopicDetail(dto,
                                                                             expectedTopicId: "t1",
                                                                             expectedRevisionId: "rev-t1").get())
        XCTAssertFalse(topic.hasMore, "hasMore 无游标时必须停止")
        XCTAssertNil(topic.nextCursor)

        if case let .failure(failure) = ExploreViewStateMapper.mapTopicDetail(dto,
                                                                              expectedTopicId: "other",
                                                                              expectedRevisionId: "rev-t1") {
            XCTAssertEqual(failure, .invalidResponse)
        } else {
            XCTFail("topic id mismatch must fail")
        }
    }

    // MARK: - 专题详情图集（TC-013-1 / TC-013-2 / TC-013-3）

    func testTopicDetailMapsOrderAndAllLayouts() throws {
        let cases: [(declared: String, count: Int, layout: ExploreImageLayout)] = [
            ("SINGLE", 1, .single),
            ("TWO_COLUMNS", 2, .twoColumns),
            ("ONE_LARGE_TWO_SMALL", 3, .oneLargeTwoSmall),
            ("TWO_BY_TWO", 4, .twoByTwo),
            ("THREE_COLUMNS", 6, .threeColumns),
            ("NINE_GRID_WITH_COUNT", 12, .nineGridWithCount)
        ]
        for item in cases {
            let images = (1...item.count).map { exploreImage("https://example.com/\($0).png") }
            let topic = try mapTopic(exploreTopicDetail(cover: exploreImage("https://example.com/card.png"),
                                                        images: images,
                                                        imageCount: item.count,
                                                        imageLayout: item.declared,
                                                        items: [exploreArticleItem("a1")]))
            XCTAssertEqual(topic.images.map(\.url?.lastPathComponent),
                           (1...item.count).map { "\($0).png" },
                           "order must follow server: \(item.declared)")
            XCTAssertEqual(topic.imageCount, item.count)
            XCTAssertEqual(topic.imageLayout, item.layout, item.declared)
            XCTAssertEqual(topic.items.map(\.id), ["a1"], "图集不得影响文章列表")
        }
    }

    func testTopicDetailExplicitEmptyImagesNeverFallsBackToCover() throws {
        let topic = try mapTopic(exploreTopicDetail(cover: exploreImage("https://example.com/card.png"),
                                                    images: [],
                                                    imageCount: 0,
                                                    imageLayout: "SINGLE",
                                                    items: [exploreArticleItem("a1")]))
        XCTAssertEqual(topic.cover?.url?.absoluteString, "https://example.com/card.png",
                       "cover 保留为兼容元数据")
        XCTAssertTrue(topic.images.isEmpty, "显式空数组不得回退 cover")
        XCTAssertEqual(topic.imageCount, 0)
        XCTAssertNil(topic.imageLayout)
        XCTAssertEqual(topic.name, "专题")
        XCTAssertEqual(topic.summary, "概要")
        XCTAssertEqual(topic.items.map(\.id), ["a1"])
    }

    func testTopicDetailMissingImagesUsesUsableCoverOnly() throws {
        let topic = try mapTopic(exploreTopicDetail(cover: exploreImage("https://example.com/card.png"),
                                                    items: [exploreArticleItem("a1")]))
        XCTAssertEqual(topic.images.map(\.url?.absoluteString),
                       ["https://example.com/card.png"])
        XCTAssertEqual(topic.imageCount, 1)
        XCTAssertEqual(topic.imageLayout, .single)
    }

    func testTopicDetailMissingImagesWithUnusableCoverHasNoMedia() throws {
        let topic = try mapTopic(exploreTopicDetail(cover: exploreImage("not a url"), items: []))
        XCTAssertTrue(topic.images.isEmpty)
        XCTAssertEqual(topic.imageCount, 0)
        XCTAssertNil(topic.imageLayout)
    }

    func testTopicDetailOnlyUsesRemainingImagesWhenFirstIsHidden() throws {
        let topic = try mapTopic(exploreTopicDetail(cover: exploreImage("https://example.com/card.png"),
                                                    images: [exploreImage("https://example.com/2.png"),
                                                             exploreImage("https://example.com/3.png")],
                                                    imageCount: 2,
                                                    imageLayout: "TWO_COLUMNS",
                                                    items: []))
        XCTAssertEqual(topic.images.map(\.url?.lastPathComponent), ["2.png", "3.png"])
        XCTAssertFalse(topic.images.contains { $0.url?.lastPathComponent == "card.png" })
        XCTAssertEqual(topic.imageCount, 2)
        XCTAssertEqual(topic.imageLayout, .twoColumns)
    }

    func testTopicDetailInvalidImagesAndUnknownLayoutFallBackSafely() throws {
        let topic = try mapTopic(exploreTopicDetail(images: [exploreImage("not a url", width: 0, height: -1),
                                                             exploreImage("https://example.com/2.png"),
                                                             exploreImage("https://example.com/3.png")],
                                                    imageCount: 3,
                                                    imageLayout: "FUTURE_LAYOUT",
                                                    items: [exploreArticleItem("a1")]))
        XCTAssertEqual(topic.images.count, 3)
        XCTAssertFalse(topic.images[0].isAvailable)
        XCTAssertNil(topic.images[0].width)
        XCTAssertNil(topic.images[0].height)
        XCTAssertEqual(topic.imageLayout, .oneLargeTwoSmall, "未知布局按数量回退")
        XCTAssertEqual(topic.items.map(\.id), ["a1"], "媒体失败不得丢文章列表")
        XCTAssertEqual(topic.summary, "概要")
    }

    func testTopicDetailDeclaredCountAloneDoesNotCreateMedia() throws {
        let topic = try mapTopic(exploreTopicDetail(cover: exploreImage("https://example.com/card.png"),
                                                    images: [],
                                                    imageCount: 5,
                                                    imageLayout: "THREE_COLUMNS",
                                                    items: []))
        XCTAssertTrue(topic.images.isEmpty, "不得凭 imageCount 构造图片")
        XCTAssertNil(topic.imageLayout)
        XCTAssertEqual(topic.imageCount, 5)
    }

    func testTopicGalleryImagesFilterInvalidURLs() throws {
        let topic = try mapTopic(exploreTopicDetail(images: [exploreImage("not a url"),
                                                             exploreImage("https://example.com/2.png")],
                                                    imageCount: 2,
                                                    imageLayout: "TWO_COLUMNS",
                                                    items: []))
        XCTAssertEqual(topic.images.count, 2, "映射层保留原数组，布局判定不变")
        XCTAssertEqual(topic.galleryImages.map(\.url?.absoluteString), ["https://example.com/2.png"],
                       "轮播只使用可用图，不展示占位空图")
    }

    func testTopicDetailIncompatibleDeclaredLayoutFallsBackByCount() throws {
        let topic = try mapTopic(exploreTopicDetail(images: [exploreImage("https://example.com/1.png"),
                                                             exploreImage("https://example.com/2.png")],
                                                    imageCount: 2,
                                                    imageLayout: "THREE_COLUMNS",
                                                    items: []))
        XCTAssertEqual(topic.imageLayout, .twoColumns)
    }

    // MARK: - 专题详情文章行（CR-013 追加）

    func testTopicArticleRowThumbnailUsesFirstAvailableImageOnly() {
        let firstInvalid = ExploreTopicArticleRowModel(item: makeRowCard(images: [rowImage(nil),
                                                                                 rowImage("https://example.com/2.png")]))
        XCTAssertNil(firstInvalid.thumbnail, "首图不可用时不拿后续图顶替")
        XCTAssertFalse(firstInvalid.showsThumbnail)

        let valid = ExploreTopicArticleRowModel(item: makeRowCard(images: [rowImage("https://example.com/1.png"),
                                                                           rowImage("https://example.com/2.png")]))
        XCTAssertEqual(valid.thumbnail?.url?.absoluteString, "https://example.com/1.png")
        XCTAssertTrue(valid.showsThumbnail)
    }

    func testTopicArticleRowWithoutImagesLeavesTextFullWidth() {
        let row = ExploreTopicArticleRowModel(item: makeRowCard(images: []))
        XCTAssertNil(row.thumbnail)
        XCTAssertFalse(row.showsThumbnail)
    }

    func testTopicArticleRowTreatsBlankTextAsMissing() {
        let row = ExploreTopicArticleRowModel(item: makeRowCard(title: "  ",
                                                                summary: "\n",
                                                                authorName: "  ",
                                                                avatar: nil))
        XCTAssertNil(row.title)
        XCTAssertNil(row.summary)
        XCTAssertNil(row.authorName)
        XCTAssertFalse(row.showsAuthorRow)
    }

    func testTopicArticleRowAuthorRowAppearsForNameOrAvatar() {
        let nameOnly = ExploreTopicArticleRowModel(item: makeRowCard(authorName: "hwyz_leo"))
        XCTAssertTrue(nameOnly.showsAuthorRow)
        XCTAssertNil(nameOnly.authorAvatarURL)

        let avatarOnly = ExploreTopicArticleRowModel(item: makeRowCard(authorName: nil,
                                                                       avatar: URL(string: "https://example.com/avatar.png")))
        XCTAssertTrue(avatarOnly.showsAuthorRow)
        XCTAssertNil(avatarOnly.authorName)

        let none = ExploreTopicArticleRowModel(item: makeRowCard(authorName: nil, avatar: nil))
        XCTAssertFalse(none.showsAuthorRow)
    }

    private func makeRowCard(title: String? = "标题",
                             summary: String? = "摘要",
                             authorName: String? = nil,
                             avatar: URL? = nil,
                             images: [ExploreImageViewState] = []) -> ExploreArticleCardViewState {
        return ExploreArticleCardViewState(id: "a1",
                                           sortNo: 0,
                                           title: title,
                                           summary: summary,
                                           authorName: authorName,
                                           authorAvatarURL: avatar,
                                           displayAt: Date(timeIntervalSince1970: 0),
                                           images: images,
                                           imageCount: images.count,
                                           imageLayout: images.isEmpty ? nil : .single,
                                           target: .invalid)
    }

    private func rowImage(_ url: String?) -> ExploreImageViewState {
        return ExploreImageViewState(url: url.flatMap { URL(string: $0) },
                                     width: 640,
                                     height: 480,
                                     mime: nil,
                                     size: nil)
    }

    private func mapTopic(_ payload: [String: Any]) throws -> ExploreTopicDetailViewState {
        let dto = try decodeExplore(ExploreTopicDetailDTO.self, payload)
        return try ExploreViewStateMapper.mapTopicDetail(dto,
                                                         expectedTopicId: "t1",
                                                         expectedRevisionId: "rev-t1").get()
    }

    func testFeedPageRejectsReleaseAndComponentMismatch() throws {
        let dto = try decodeExplore(ExploreFeedPageDTO.self,
                                    exploreFeedPage(releaseId: "release-2",
                                                    componentId: "feed-1",
                                                    items: []))
        if case let .failure(failure) = ExploreViewStateMapper.mapFeedPage(dto,
                                                                           expectedReleaseId: "release-1",
                                                                           expectedComponentId: "feed-1") {
            XCTAssertEqual(failure, .releaseChanged)
        } else {
            XCTFail("release mismatch must fail")
        }

        let dto2 = try decodeExplore(ExploreFeedPageDTO.self,
                                     exploreFeedPage(releaseId: "release-1",
                                                     componentId: "feed-2",
                                                     items: []))
        if case let .failure(failure) = ExploreViewStateMapper.mapFeedPage(dto2,
                                                                           expectedReleaseId: "release-1",
                                                                           expectedComponentId: "feed-1") {
            XCTAssertEqual(failure, .invalidArgument)
        } else {
            XCTFail("component mismatch must fail")
        }
    }
}
