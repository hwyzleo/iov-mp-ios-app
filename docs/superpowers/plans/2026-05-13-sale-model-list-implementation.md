# 购车页销售车型列表功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 购车页从后端动态获取销售车型列表，支持多个车型通过标签和滑动切换展示。

**Architecture:** MVI 模式，数据流：API → Service → Intent → Model → Page。新增 SaleModelMp 数据结构，扩展 MarketingIndexModel 支持车型列表状态，重构 NoOrder 页面添加标签栏和滑动列表。

**Tech Stack:** Swift, SwiftUI, Alamofire

---

## 文件结构

| 文件 | 变更 | 责责 |
|------|------|------|
| `iov/iov/Data/Bean/HttpBean.swift` | 新增 | `SaleModelMp` 数据结构 |
| `iov/iov/Data/Http/TspApi.swift` | 新增 | `getSaleModelList()` API |
| `iov/iov/Data/Bean/MockBean.swift` | 新增 | mock 数据函数 |
| `iov/iov/Module/Marketing/Service/MarketingService.swift` | 扩展 | Protocol + Real + Mock 实现 |
| `iov/iov/Module/Marketing/Model/MarketingIndexModel.swift` | 扩展 | 新增状态属性和方法 |
| `iov/iov/Module/Marketing/Model/MarketingIndexModelProtocol.swift` | 扩展 | Protocol 新增定义 |
| `iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift` | 重构 | viewOnAppear 流程 |
| `iov/iov/Module/Marketing/Intent/MarketingIndexIntentProtocol.swift` | 扩展 | 新增 onTapSelectSaleModel |
| `iov/iov/Module/Marketing/Page/MarketingIndexPage_NoOrder.swift` | 重构 | 标签栏 + 滑动列表 |

---

## Task 1: 数据层 - SaleModelMp 结构体

**Files:**
- Modify: `iov/iov/Data/Bean/HttpBean.swift` (末尾追加)

- [ ] **Step 1: 添加 SaleModelMp 结构体**

在 `HttpBean.swift` 文件末尾（`InitiatePaymentResult` 结构体之后）添加：

```swift
/// 销售车型（手机端）
struct SaleModelMp: Codable, Identifiable {
    /// 销售车型代码
    var saleModelCode: String
    /// 销售车型名称
    var modelName: String
    /// 销售车型图片集
    var images: [String]
    /// 是否允许意向金
    var earnestMoney: Bool
    /// 意向金价格
    var earnestMoneyPrice: Decimal
    /// 是否允许定金
    var downPayment: Bool
    /// 定金价格
    var downPaymentPrice: Decimal
    
    var id: String { saleModelCode }
}
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Data/Bean/HttpBean.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Data/Bean/HttpBean.swift
git commit -m "feat: add SaleModelMp data structure"
```

---

## Task 2: 数据层 - getSaleModelList API

**Files:**
- Modify: `iov/iov/Data/Http/TspApi.swift:85` (在 `getMyVehicleList` 之后)

- [ ] **Step 1: 添加 getSaleModelList API 方法**

在 `TspApi.swift` 第 84 行（`getMyVehicleList` 方法结束后）添加：

```swift
/// 获取销售车型列表
static func getSaleModelList(completion: @escaping (Result<TspResponse<[SaleModelMp]>, Error>) -> Void) {
    TspManager.requestGet(path: "/api/mobile/saleModel/v1", parameters: [:]) { (result: Result<TspResponse<[SaleModelMp]>, Error>) in
        completion(result)
    }
}
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Data/Http/TspApi.swift iov/iov/Data/Bean/HttpBean.swift iov/iov/Data/Http/TspManager.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Data/Http/TspApi.swift
git commit -m "feat: add getSaleModelList API"
```

---

## Task 3: 数据层 - Mock 数据

**Files:**
- Modify: `iov/iov/Data/Bean/MockBean.swift` (末尾追加)

- [ ] **Step 1: 添加 mockSaleModelList 函数**

在 `MockBean.swift` 文件末尾添加：

```swift
func mockSaleModelList() -> [SaleModelMp] {
    return [
        SaleModelMp(
            saleModelCode: "HS5",
            modelName: "寒01",
            images: [
                "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png",
                "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
            ],
            earnestMoney: true,
            earnestMoneyPrice: 5000,
            downPayment: true,
            downPaymentPrice: 10000
        ),
        SaleModelMp(
            saleModelCode: "HS7",
            modelName: "寒03",
            images: [
                "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png",
                "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
            ],
            earnestMoney: true,
            earnestMoneyPrice: 5000,
            downPayment: true,
            downPaymentPrice: 15000
        )
    ]
}
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Data/Bean/MockBean.swift iov/iov/Data/Bean/HttpBean.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Data/Bean/MockBean.swift
git commit -m "feat: add mockSaleModelList function"
```

---

## Task 4: Service 层 - Protocol 扩展

**Files:**
- Modify: `iov/iov/Module/Marketing/Service/MarketingService.swift:28` (Protocol 末尾)

- [ ] **Step 1: 添加 getSaleModelList 到 Protocol**

在 `MarketingServiceProtocol` 第 28 行（`lockOrder` 之后）添加：

```swift
func getSaleModelList(completion: @escaping (Result<TspResponse<[SaleModelMp]>, Error>) -> Void)
```

- [ ] **Step 2: 提交**

```bash
git add iov/iov/Module/Marketing/Service/MarketingService.swift
git commit -m "feat: add getSaleModelList to MarketingServiceProtocol"
```

---

## Task 5: Service 层 - RealMarketingService 实现

**Files:**
- Modify: `iov/iov/Module/Marketing/Service/MarketingService.swift:118` (RealMarketingService 末尾)

- [ ] **Step 1: 添加 RealMarketingService 实现**

在 `RealMarketingService` 类第 118 行（`lockOrder` 方法之后）添加：

```swift
func getSaleModelList(completion: @escaping (Result<TspResponse<[SaleModelMp]>, Error>) -> Void) {
    TspApi.getSaleModelList(completion: completion)
}
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Module/Marketing/Service/MarketingService.swift iov/iov/Data/Http/TspApi.swift iov/iov/Data/Bean/HttpBean.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Module/Marketing/Service/MarketingService.swift
git commit -m "feat: implement getSaleModelList in RealMarketingService"
```

---

## Task 6: Service 层 - MockMarketingService 实现

**Files:**
- Modify: `iov/iov/Module/Marketing/Service/MarketingService.swift:282` (MockMarketingService 末尾)

- [ ] **Step 1: 添加 MockMarketingService 实现**

在 `MockMarketingService` 类第 282 行（`lockOrder` 方法之后）添加：

```swift
func getSaleModelList(completion: @escaping (Result<TspResponse<[SaleModelMp]>, Error>) -> Void) {
    mockDelayedSuccess(data: mockSaleModelList(), completion: completion)
}
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Module/Marketing/Service/MarketingService.swift iov/iov/Data/Http/TspApi.swift iov/iov/Data/Bean/HttpBean.swift iov/iov/Data/Bean/MockBean.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Module/Marketing/Service/MarketingService.swift
git commit -m "feat: implement getSaleModelList in MockMarketingService"
```

---

## Task 7: Model 层 - Protocol State 扩展

**Files:**
- Modify: `iov/iov/Module/Marketing/Model/MarketingIndexModelProtocol.swift:21` (State Protocol 末尾)

- [ ] **Step 1: 添加状态属性到 MarketingIndexModelStateProtocol**

在 `MarketingIndexModelStateProtocol` 第 20 行（`saleModelDesc` 之后）添加：

```swift
var saleModelList: [SaleModelMp] { get }
var selectedSaleModelIndex: Int { get }
```

- [ ] **Step 2: 提交**

```bash
git add iov/iov/Module/Marketing/Model/MarketingIndexModelProtocol.swift
git commit -m "feat: add saleModelList state to MarketingIndexModelStateProtocol"
```

---

## Task 8: Model 层 - Protocol Action 扩展

**Files:**
- Modify: `iov/iov/Module/Marketing/Model/MarketingIndexModelProtocol.swift:34` (Action Protocol 末尾)

- [ ] **Step 1: 添加 Action 方法到 MarketingIndexModelActionProtocol**

在 `MarketingIndexModelActionProtocol` 第 33 行（`displayVehicle` 之后）添加：

```swift
func displaySaleModelList(saleModelList: [SaleModelMp])
func selectSaleModel(index: Int)
func getCurrentSaleModel() -> SaleModelMp?
```

- [ ] **Step 2: 提交**

```bash
git add iov/iov/Module/Marketing/Model/MarketingIndexModelProtocol.swift
git commit -m "feat: add saleModelList actions to MarketingIndexModelActionProtocol"
```

---

## Task 9: Model 层 - MarketingIndexModel 状态属性

**Files:**
- Modify: `iov/iov/Module/Marketing/Model/MarketingIndexModel.swift:20` (Model 类属性区域)

- [ ] **Step 1: 添加状态属性到 MarketingIndexModel**

在 `MarketingIndexModel` 类第 19 行（`saleModelDesc` 之后）添加：

```swift
@Published var saleModelList: [SaleModelMp] = []
@Published var selectedSaleModelIndex: Int = 0
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Module/Marketing/Model/MarketingIndexModel.swift iov/iov/Data/Bean/HttpBean.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Module/Marketing/Model/MarketingIndexModel.swift
git commit -m "feat: add saleModelList state properties to MarketingIndexModel"
```

---

## Task 10: Model 层 - MarketingIndexModel Action 方法

**Files:**
- Modify: `iov/iov/Module/Marketing/Model/MarketingIndexModel.swift:63` (Action 区域末尾)

- [ ] **Step 1: 添加 displaySaleModelList 方法**

在 `MarketingIndexModel` 的 Action extension 第 62 行（`displayVehicle` 方法之后）添加：

```swift
func displaySaleModelList(saleModelList: [SaleModelMp]) {
    self.saleModelList = saleModelList
    if !saleModelList.isEmpty {
        self.selectedSaleModelIndex = 0
    }
    contentState = .content
}

func selectSaleModel(index: Int) {
    guard index >= 0 && index < saleModelList.count else { return }
    self.selectedSaleModelIndex = index
}

func getCurrentSaleModel() -> SaleModelMp? {
    guard selectedSaleModelIndex >= 0 && selectedSaleModelIndex < saleModelList.count else { return nil }
    return saleModelList[selectedSaleModelIndex]
}
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Module/Marketing/Model/MarketingIndexModel.swift iov/iov/Data/Bean/HttpBean.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Module/Marketing/Model/MarketingIndexModel.swift
git commit -m "feat: implement saleModelList action methods in MarketingIndexModel"
```

---

## Task 11: Intent 层 - Protocol 扩展

**Files:**
- Modify: `iov/iov/Module/Marketing/Intent/MarketingIndexIntentProtocol.swift:26` (末尾)

- [ ] **Step 1: 添加 onTapSelectSaleModel 到 Protocol**

在 `MarketingIndexIntentProtocol` 第 26 行（`onTapLockOrder` 之后）添加：

```swift
func onTapSelectSaleModel(index: Int)
```

- [ ] **Step 2: 提交**

```bash
git add iov/iov/Module/Marketing/Intent/MarketingIndexIntentProtocol.swift
git commit -m "feat: add onTapSelectSaleModel to MarketingIndexIntentProtocol"
```

---

## Task 12: Intent 层 - MarketingIndexIntent viewOnAppear 重构

**Files:**
- Modify: `iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift:19-78`

- [ ] **Step 1: 重构 viewOnAppear 方法**

将现有的 `viewOnAppear` 方法（第 19-78 行）替换为：

```swift
func viewOnAppear() {
    modelAction?.displayLoading()
    ServiceContainer.marketingService.getSaleModelList { [weak self] result in
        switch result {
        case .success(let res):
            if res.isSuccess, let saleModelList = res.data, !saleModelList.isEmpty {
                self?.modelAction?.displaySaleModelList(saleModelList: saleModelList)
                if UserManager.isLogin() {
                    self?.fetchMyVehicleList()
                }
            } else {
                self?.modelAction?.displayError(text: "获取车型列表失败")
            }
        case .failure(_):
            self?.modelAction?.displayError(text: "请求异常")
        }
    }
}

private func fetchMyVehicleList() {
    ServiceContainer.marketingService.getMyVehicleList { [weak self] (result: Result<TspResponse<[MyVehicleVo]>, Error>) in
        switch result {
        case .success(let res):
            if res.isSuccess {
                guard let resData = res.data else {
                    self?.modelAction?.displayError(text: "数据异常")
                    return
                }
                VehicleManager.shared.update(myVehicleList: resData)
                
                if resData.isEmpty {
                    self?.modelAction?.displayNoOrder()
                    return
                }
                
                if let vehiclePo = VehicleManager.shared.getCurrentVehicle(), let vehicleId = VehicleManager.shared.getCurrentVehicleId() {
                    switch vehiclePo.type {
                    case .WISHLIST:
                        ServiceContainer.marketingService.getWishlist(wishlistId: vehicleId) { (result: Result<TspResponse<Wishlist>, Error>) in
                            switch result {
                            case .success(let res):
                                guard let wishlist = res.data else {
                                    self?.modelAction?.displayError(text: "数据异常")
                                    return
                                }
                                self?.modelAction?.displayWishlist(wishlist: wishlist)
                            case .failure(_):
                                self?.modelAction?.displayError(text: "请求异常")
                            }
                        }
                    case .ORDER:
                        ServiceContainer.marketingService.getOrder(orderNo: vehicleId) { (result: Result<TspResponse<Order>, Error>) in
                            switch result {
                            case .success(let res):
                                guard let order = res.data else {
                                    self?.modelAction?.displayError(text: "数据异常")
                                    return
                                }
                                self?.modelAction?.displayOrder(order: order)
                            case .failure(_):
                                self?.modelAction?.displayError(text: "请求异常")
                            }
                        }
                    case .ACTIVATED:
                        self?.modelAction?.displayVehicle()
                    }
                } else {
                    self?.modelAction?.displayNoOrder()
                }
            } else {
                self?.modelAction?.displayError(text: res.message ?? "请求异常")
            }
        case .failure(_):
            self?.modelAction?.displayError(text: "请求异常")
        }
    }
}
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift iov/iov/Module/Marketing/Model/MarketingIndexModel.swift iov/iov/Module/Marketing/Service/MarketingService.swift iov/iov/Data/Bean/HttpBean.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift
git commit -m "refactor: viewOnAppear to fetch saleModelList first"
```

---

## Task 13: Intent 层 - onTapSelectSaleModel 实现

**Files:**
- Modify: `iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift` (Intent extension 区域)

- [ ] **Step 1: 添加 onTapSelectSaleModel 方法**

在 `MarketingIndexIntent` 的 Protocol extension 区域（`onTapModelConfig` 之前）添加：

```swift
func onTapSelectSaleModel(index: Int) {
    modelAction?.selectSaleModel(index: index)
}
```

- [ ] **Step 2: 提交**

```bash
git add iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift
git commit -m "feat: implement onTapSelectSaleModel"
```

---

## Task 14: Intent 层 - onTapModelConfig 修改

**Files:**
- Modify: `iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift` (onTapModelConfig 方法)

- [ ] **Step 1: 修改 onTapModelConfig 方法**

找到现有的 `onTapModelConfig` 方法，替换为：

```swift
func onTapModelConfig() {
    if UserManager.isLogin() {
        guard let saleModel = modelAction?.getCurrentSaleModel() else { return }
        AppGlobalState.shared.parameters["saleModelCode"] = saleModel.saleModelCode
        self.modelRouter?.routeToModelConfig()
    } else {
        self.modelRouter?.routeToLogin()
    }
}
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift iov/iov/Module/Marketing/Model/MarketingIndexModel.swift iov/iov/Data/Bean/HttpBean.swift iov/iov/Utils/AppGlobalState.swift iov/iov/Utils/UserManager.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift
git commit -m "refactor: onTapModelConfig to use saleModelCode from selected model"
```

---

## Task 15: Page 层 - NoOrder 页面重构

**Files:**
- Modify: `iov/iov/Module/Marketing/Page/MarketingIndexPage_NoOrder.swift`

- [ ] **Step 1: 重构 NoOrder 视图**

将 `MarketingIndexPage_NoOrder.swift` 整个文件替换为：

```swift
//
//  MarketingIndexPage_NoOrder.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import SwiftUI
import Kingfisher

extension MarketingIndexPage {
    struct NoOrder: View {
        @StateObject var container: MviContainer<MarketingIndexIntentProtocol, MarketingIndexModelStateProtocol>
        private var intent: MarketingIndexIntentProtocol { container.intent }
        private var state: MarketingIndexModelStateProtocol { container.model }
        
        var body: some View {
            ZStack(alignment: .bottom) {
                SaleModelImageSlider(
                    saleModelList: state.saleModelList,
                    selectedIndex: state.selectedSaleModelIndex,
                    onIndexChange: { index in intent.onTapSelectSaleModel(index: index) }
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    if state.saleModelList.count > 1 {
                        SaleModelTabBar(
                            saleModelList: state.saleModelList,
                            selectedIndex: state.selectedSaleModelIndex,
                            onTap: { index in intent.onTapSelectSaleModel(index: index) }
                        )
                        .padding(.top, kStatusBarHeight)
                    }
                    
                    Spacer()
                    
                    RoundedCornerButton(nameLocal: LocalizedStringKey("order_now")) {
                        intent.onTapModelConfig()
                    }
                    .frame(width: 300)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

struct SaleModelTabBar: View {
    var saleModelList: [SaleModelMp]
    var selectedIndex: Int
    var onTap: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<saleModelList.count, id: \.self) { index in
                Text(saleModelList[index].modelName)
                    .font(selectedIndex == index ? AppTheme.fonts.title1 : AppTheme.fonts.body)
                    .foregroundColor(selectedIndex == index ? AppTheme.colors.brandMain : AppTheme.colors.fontSecondary)
                    .onTapGesture { onTap(index) }
            }
        }
        .padding(.horizontal, AppTheme.layout.margin)
        .padding(.vertical, 12)
    }
}

struct SaleModelImageSlider: View {
    var saleModelList: [SaleModelMp]
    var selectedIndex: Int
    var onIndexChange: (Int) -> Void
    
    @State private var currentImageIndex: Int = 0
    
    var body: some View {
        TabView(selection: Binding(
            get: { selectedIndex },
            set: { onIndexChange($0) }
        )) {
            ForEach(0..<saleModelList.count, id: \.self) { modelIndex in
                let model = saleModelList[modelIndex]
                if !model.images.isEmpty {
                    KFImage(URL(string: model.images.first ?? ""))
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
                .tag(modelIndex)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct MarketingIndexPage_NoOrder_Previews: PreviewProvider {
    static var previews: some View {
        MarketingIndexPage.NoOrder(container: MarketingIndexPage.buildContainer())
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
```

- [ ] **Step 2: 验证语法正确**

```bash
swiftc -parse iov/iov/Module/Marketing/Page/MarketingIndexPage_NoOrder.swift iov/iov/Module/Marketing/Intent/MarketingIndexIntentProtocol.swift iov/iov/Module/Marketing/Model/MarketingIndexModelProtocol.swift iov/iov/Data/Bean/HttpBean.swift
```
Expected: 无错误输出

- [ ] **Step 3: 提交**

```bash
git add iov/iov/Module/Marketing/Page/MarketingIndexPage_NoOrder.swift
git commit -m "refactor: NoOrder page with SaleModelTabBar and ImageSlider"
```

---

## Task 16: 最终验证

- [ ] **Step 1: 编译验证**

```bash
cd iov && xcodebuild -scheme iov -destination 'platform=iOS Simulator,id=137E2ED3-40D3-4A34-B5C6-87B2285A51AE' -quiet build 2>&1 | grep -E "error:|BUILD"
```
Expected: BUILD SUCCEEDED (可能因 JPUSH 依赖缺失失败，检查 Swift 语法错误即可)

- [ ] **Step 2: 查看所有改动**

```bash
git status
git diff --stat
```

- [ ] **Step 3: 提交设计文档**

```bash
git add docs/superpowers/specs/2026-05-13-sale-model-list-design.md
git commit -m "docs: add sale model list feature design spec"
```

---

## 实现顺序总结

1. Task 1-3: 数据层 (HttpBean, TspApi, MockBean)
2. Task 4-6: Service 层
3. Task 7-10: Model 层
4. Task 11-14: Intent 层
5. Task 15: Page 层
6. Task 16: 最终验证