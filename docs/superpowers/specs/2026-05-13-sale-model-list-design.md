# 购车页销售车型列表功能设计

## 概述

当前购车页 (`MarketingIndexPage`) 在无订单状态下，销售车型代码 (`saleModelCode`) 被硬编码为 `"HS5"`。本设计将其改为从后端动态获取销售车型列表，支持多个车型的切换展示。

## 背景

### 现有问题
1. `VehicleModelConfigIntent.swift:29` 硬编码 `saleCode = "HS5"`
2. `onTapModelConfig()` 和 `onTapModifySaleModel()` 未设置 `saleModelCode` 参数
3. 无订单页无法展示多个销售车型选项

### 后端接口
- **路径**: `/api/mobile/saleModel/v1`
- **方法**: GET
- **响应**: `List<SaleModelMp>`

### 数据结构 (SaleModelMp)
```
saleModelCode: String      // 销售车型代码
modelName: String          // 销售车型名称
images: [String]           // 图片列表
earnestMoney: Bool         // 是否支持意向金
earnestMoneyPrice: Decimal // 意向金价格
downPayment: Bool          // 是否支持定金
downPaymentPrice: Decimal  // 定金价格
```

## 设计详情

### 1. 数据层

#### 1.1 新增数据结构
**文件**: `iov/iov/Data/Bean/HttpBean.swift`

新增 `SaleModelMp` 结构体：
```swift
struct SaleModelMp: Codable, Identifiable {
    var saleModelCode: String
    var modelName: String
    var images: [String]
    var earnestMoney: Bool
    var earnestMoneyPrice: Decimal
    var downPayment: Bool
    var downPaymentPrice: Decimal
    
    var id: String { saleModelCode }
}
```

#### 1.2 新增 API
**文件**: `iov/iov/Data/Http/TspApi.swift`

新增方法：
```swift
static func getSaleModelList(completion: @escaping (Result<TspResponse<[SaleModelMp]>, Error>) -> Void) {
    TspManager.requestGet(path: "/api/mobile/saleModel/v1", parameters: [:]) { 
        (result: Result<TspResponse<[SaleModelMp]>, Error>) in
        completion(result)
    }
}
```

#### 1.3 新增 Mock 数据
**文件**: `iov/iov/Data/Bean/MockBean.swift`

新增 mockSaleModelList() 函数，返回包含多个车型的测试数据。

---

### 2. Service 层

**文件**: `iov/iov/Module/Marketing/Service/MarketingService.swift`

#### 2.1 Protocol 扩展
```swift
func getSaleModelList(completion: @escaping (Result<TspResponse<[SaleModelMp]>, Error>) -> Void)
```

#### 2.2 实现类扩展
- **RealMarketingService**: 调用 `TspApi.getSaleModelList()`
- **MockMarketingService**: 调用 `mockSaleModelList()`

---

### 3. Model 层

**文件**: `iov/iov/Module/Marketing/Model/MarketingIndexModel.swift`

#### 3.1 新增状态属性
```swift
@Published var saleModelList: [SaleModelMp] = []
@Published var selectedSaleModelIndex: Int = 0
```

#### 3.2 新增 Action 方法
```swift
func displaySaleModelList(saleModelList: [SaleModelMp]) {
    self.saleModelList = saleModelList
    if !saleModelList.isEmpty {
        self.selectedSaleModelIndex = 0
    }
    contentState = .content
}

func selectSaleModel(index: Int) {
    self.selectedSaleModelIndex = index
}

func getCurrentSaleModel() -> SaleModelMp? {
    guard selectedSaleModelIndex < saleModelList.count else { return nil }
    return saleModelList[selectedSaleModelIndex]
}
```

#### 3.3 修改 Protocol
**文件**: `iov/iov/Module/Marketing/Model/MarketingIndexModelProtocol.swift`

新增：
```swift
var saleModelList: [SaleModelMp] { get }
var selectedSaleModelIndex: Int { get set }
func displaySaleModelList(saleModelList: [SaleModelMp])
func selectSaleModel(index: Int)
func getCurrentSaleModel() -> SaleModelMp?
```

---

### 4. Intent 层

**文件**: `iov/iov/Module/Marketing/Intent/MarketingIndexIntent.swift`

#### 4.1 修改 viewOnAppear()
```swift
func viewOnAppear() {
    modelAction?.displayLoading()
    // 无论是否登录，都获取销售车型列表供展示
    ServiceContainer.marketingService.getSaleModelList { [weak self] result in
        switch result {
        case .success(let res):
            if res.isSuccess, let saleModelList = res.data, !saleModelList.isEmpty {
                self?.modelAction?.displaySaleModelList(saleModelList: saleModelList)
                // 已登录时，再获取我的车辆列表
                if UserManager.isLogin() {
                    self?.fetchMyVehicleList()
                }
            } else {
                self?.modelAction?.displayError(text: "获取车型列表失败")
            }
        case .failure:
            self?.modelAction?.displayError(text: "请求异常")
        }
    }
}

private func fetchMyVehicleList() {
    ServiceContainer.marketingService.getMyVehicleList { ... }
}
```

#### 4.2 新增 onTapSelectSaleModel()
```swift
func onTapSelectSaleModel(index: Int) {
    modelAction?.selectSaleModel(index: index)
}
```

#### 4.3 修改 onTapModelConfig()
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

#### 4.4 IntentProtocol 扩展
**文件**: `iov/iov/Module/Marketing/Intent/MarketingIndexIntentProtocol.swift`

新增：
```swift
func onTapSelectSaleModel(index: Int)
```

---

### 5. Page 层

**文件**: `iov/iov/Module/Marketing/Page/MarketingIndexPage_NoOrder.swift`

#### 5.1 重构 NoOrder 视图
```swift
struct NoOrder: View {
    @StateObject var container: ...
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部车型标签栏
            if state.saleModelList.count > 1 {
                SaleModelTabBar(
                    saleModelList: state.saleModelList,
                    selectedIndex: state.selectedSaleModelIndex,
                    onTap: { index in intent.onTapSelectSaleModel(index: index) }
                )
            }
            
            // 车型图片滑动区
            SaleModelImageSlider(
                saleModelList: state.saleModelList,
                selectedIndex: state.selectedSaleModelIndex,
                onIndexChange: { index in intent.onTapSelectSaleModel(index: index) }
            )
            
            Spacer().frame(height: 650)
            
            // 立即订购按钮
            RoundedCornerButton(nameLocal: "order_now") {
                intent.onTapModelConfig()
            }
            .frame(width: 300)
        }
        .edgesIgnoringSafeArea(.top)
    }
}
```

#### 5.2 新增 SaleModelTabBar 组件
```swift
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
```

#### 5.3 新增 SaleModelImageSlider 组件
```swift
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
                ModelImagesView(images: model.images, currentImageIndex: $currentImageIndex)
                    .tag(modelIndex)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 300)
    }
}
```

---

### 6. 数据流

```
┌─────────────────────────────────────────────────────────────┐
│                     MarketingIndexPage                       │
│  onAppear → intent.viewOnAppear()                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   MarketingIndexIntent                       │
│  1. getSaleModelList() → 获取车型列表                        │
│  2. getMyVehicleList() → 获取我的车辆                        │
│  3. 根据是否有订单决定显示模式                                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   MarketingIndexModel                        │
│  saleModelList: [SaleModelMp]                                │
│  selectedSaleModelIndex: Int                                 │
│  hasOrder: Bool                                              │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌──────────────────────┐        ┌──────────────────────┐
│   NoOrder (新)       │        │   Order (现有)       │
│ - 车型标签栏         │        │ - 订单/心愿单详情    │
│ - 图片滑动区         │        │ - 支付/修改按钮      │
│ - 立即订购按钮       │        └──────────────────────┘
└──────────────────────┘
              │
              ▼ onTapModelConfig()
┌─────────────────────────────────────────────────────────────┐
│                VehicleModelConfigPage                        │
│  使用 saleModelCode 进入配置页                              │
└─────────────────────────────────────────────────────────────┘
```

---

### 7. 错误处理

| 场景 | 处理方式 |
|------|----------|
| 车型列表为空 | 显示错误提示 "获取车型列表失败" |
| 网络请求失败 | 显示错误提示 "请求异常" |
| 用户未登录 | 正常展示车型列表，点击"立即订购"时跳转登录页 |
| 进入配置页时 saleModelCode 为空 | 已修复（显示"销售车型代码不能为空"） |

---

### 8. Mock 数据示例

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

---

### 9. 文件变更清单

| 文件路径 | 变更类型 | 说明 |
|----------|----------|------|
| `Data/Bean/HttpBean.swift` | 新增 | `SaleModelMp` 结构体 |
| `Data/Http/TspApi.swift` | 新增 | `getSaleModelList()` API |
| `Data/Bean/MockBean.swift` | 新增 | mock 数据 |
| `Module/Marketing/Service/MarketingService.swift` | 扩展 | 新增接口方法 |
| `Module/Marketing/Model/MarketingIndexModel.swift` | 扩展 | 新增状态属性和方法 |
| `Module/Marketing/Model/MarketingIndexModelProtocol.swift` | 扩展 | Protocol 新增定义 |
| `Module/Marketing/Intent/MarketingIndexIntent.swift` | 重构 | viewOnAppear 流程重构 |
| `Module/Marketing/Intent/MarketingIndexIntentProtocol.swift` | 扩展 | 新增 onTapSelectSaleModel |
| `Module/Marketing/Page/MarketingIndexPage_NoOrder.swift` | 重构 | 新增标签栏和滑动列表 |
| `Module/Marketing/Intent/VehicleModelConfigIntent.swift` | 已修复 | saleModelCode 参数 |
| `Module/Marketing/Intent/VehicleOrderDetailIntent.swift` | 已修复 | onTapModifySaleModel |

---

### 10. 测试要点

1. **正常流程**: 进入购车页 → 获取车型列表 → 展示标签/图片 → 点击配置
2. **多车型切换**: 点击标签切换 → 图片联动切换 → 滑动图片切换
3. **单车型**: 无标签栏，直接展示图片
4. **空列表**: 显示错误提示
5. **有订单**: 仍显示现有订单详情页
6. **配置页**: 传递正确的 saleModelCode

---

## 实现顺序建议

1. 数据层 (HttpBean, TspApi, MockBean)
2. Service 层
3. Model 层
4. Intent 层
5. Page 层