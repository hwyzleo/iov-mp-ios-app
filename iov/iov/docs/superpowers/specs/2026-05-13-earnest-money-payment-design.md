# 意向金支付页面设计文档

## 背景

后端接口 `earnestMoneyOrder` 返回值已调整，新增支付相关信息。手机端需要新增完整的支付流程页面，支持：
- 展示支付渠道列表
- 显示意向金金额
- 倒计时显示
- 用户选择支付渠道并发起支付
- 模拟支付完成后通知后端

## 后端接口变化

### 1. earnestMoneyOrder 返回值

原返回 `String`（订单号），现返回 `EarnestMoneyOrderResult`：

```java
public class EarnestMoneyOrderResult {
    private String smallOrderNo;           // 小订单号
    private BigDecimal earnestMoneyAmount; // 意向金金额
    private List<PaymentChannelInfo> paymentChannels; // 支付渠道列表
    private LocalDateTime expireTime;      // 过期时间

    public static class PaymentChannelInfo {
        private PaymentChannel channelCode; // UNION_PAY, WECHAT, ALIPAY
        private String channelName;
        private Boolean isDefault;
    }
}
```

### 2. 新增 initiatePayment 接口

用于发起支付：
- 请求：`smallOrderNo` + `paymentChannel`
- 返回：`paymentNo`, `paymentChannel`, `paymentAmount`, `paymentMerchant`, `paymentReference`

### 3. 支付回调接口

真实支付通过 `/api/open/callback/v1/payment` 回调，模拟场景也需要调用此接口。

## 设计方案

### 模块结构

新建独立支付模块 `Marketing/Sub/Payment/`，采用MVI架构：

```
Marketing/Sub/Payment/
├── Intent/
│   ├── EarnestMoneyPayIntent.swift
│   └── EarnestMoneyPayIntentProtocol.swift
├── Model/
│   ├── EarnestMoneyPayModel.swift
│   └── EarnestMoneyPayModelProtocol.swift
├── Page/
│   ├── EarnestMoneyPayPage.swift
│   └── EarnestMoneyPayPage+Build.swift
├── Router/
│   └── EarnestMoneyPayRouter.swift
└── EarnestMoneyPayTypes.swift
```

### 数据流

```
用户点击意向金下单
    ↓
调用 earnestMoneyOrder 接口
    ↓
返回 EarnestMoneyOrderResult
    ↓
Push到 EarnestMoneyPayPage（传入支付信息）
    ↓
展示支付渠道列表 + 倒计时
    ↓
用户选择渠道 → 调用 initiatePayment
    ↓
模拟支付过程（loading + 2秒延迟）
    ↓
调用 paymentCallback 模拟回调
    ↓
Pop返回 → 刷新订单详情页
```

### 数据结构

#### Swift 数据模型

```swift
struct EarnestMoneyPayInfo: Codable {
    let smallOrderNo: String
    let earnestMoneyAmount: Decimal
    let paymentChannels: [PaymentChannelInfo]
    let expireTime: Int64  // 时间戳

    static func from(result: EarnestMoneyOrderResult) -> EarnestMoneyPayInfo
}

struct PaymentChannelInfo: Codable, Identifiable {
    let channelCode: String  // UNION_PAY, WECHAT, ALIPAY
    let channelName: String
    let isDefault: Bool
    
    var id: String { channelCode }
}

struct InitiatePaymentResult: Codable {
    let paymentNo: String
    let paymentChannel: String
    let paymentAmount: Decimal
    let paymentMerchant: String
    let paymentReference: String
}
```

#### 页面状态

```swift
enum EarnestMoneyPayContentState {
    case loading    // 加载中
    case ready      // 显示支付渠道选择
    case paying     // 支付进行中
    case success    // 支付成功
    case failed     // 支付失败
    case expired    // 超时过期
}
```

### UI 设计

```
┌────────────────────────────┐
│  ←  意向金支付              │ 顶部导航栏
├────────────────────────────┤
│                            │
│    支付金额                 │
│   ¥ 5,000.00               │ 金额显示（大字体）
│                            │
│    剩余时间 14:59           │ 倒计时显示
│                            │
├────────────────────────────┤
│    选择支付方式             │
│                            │
│  ○ 微信支付      [默认]    │ 渠道选项列表
│  ○ 支付宝支付              │ (从paymentChannels动态生成)
│  ○ 银联支付                │
│                            │
├────────────────────────────┤
│    付款说明                 │
│  意向金可随时退还...        │ 说明文字
│                            │
├────────────────────────────┤
│                            │
│  [ 立即支付 ]               │ 底部支付按钮
│                            │
└────────────────────────────┘
```

### 关键交互逻辑

#### 1. 倒计时
- 页面进入时启动 Timer，每秒更新剩余时间
- 剩余时间 = expireTime - 当前时间
- 超时自动切换到 `expired` 状态，禁用支付按钮

#### 2. 渠道选择
- 默认选中 `isDefault = true` 的渠道
- 点击切换选中状态
- 单选模式

#### 3. 支付流程
```
点击"立即支付"
    ↓
状态切换为 paying，显示 loading
    ↓
调用 initiatePayment(smallOrderNo, paymentChannel)
    ↓
模拟等待 2 秒（模拟第三方支付过程）
    ↓
调用 paymentCallback 模拟回调
    ↓
成功后切换为 success 状态
    ↓
显示成功提示 2 秒
    ↓
Pop 返回上一页
    ↓
触发订单详情页刷新
```

## API 调整清单

### TspApi.swift

1. 修改 `earnestMoneyOrder` 返回类型：
   - 原：`Result<TspResponse<String>, Error>`
   - 新：`Result<TspResponse<EarnestMoneyOrderResult>, Error>`

2. 新增接口：
```swift
static func initiatePayment(
    smallOrderNo: String,
    paymentChannel: String,
    completion: @escaping (Result<TspResponse<InitiatePaymentResult>, Error>) -> Void
)

static func paymentCallback(
    paymentNo: String,
    completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void
)
```

### MarketingService.swift

相应更新服务层接口。

### HttpBean.swift

新增数据结构：
- `EarnestMoneyOrderResult`
- `PaymentChannelInfo`
- `InitiatePaymentResult`

## 入口集成

修改 `VehicleOrderDetailIntent.swift` 的 `onTapEarnestMoneyOrder` 方法：

```swift
func onTapEarnestMoneyOrder(saleModelName: String, licenseCityCode: String) {
    // 调用接口获取支付信息
    ServiceContainer.marketingService.earnestMoneyOrder(...) { result in
        switch result {
        case .success(let res):
            // 将支付信息存入 AppGlobalState.parameters
            AppGlobalState.shared.parameters["earnestMoneyPayInfo"] = res.data
            // 跳转到支付页面
            self.modelRouter?.pushScreen(.earnestMoneyPay)
        case .failure:
            self.modelAction?.displayError(...)
        }
    }
}
```

### MarketingRouter.swift

新增 ScreenType：
```swift
enum ScreenType: RouterScreenProtocol {
    // ... existing cases
    case earnestMoneyPay
}
```

## 测试要点

1. 倒计时正常显示并更新
2. 超时后页面状态正确切换
3. 支付渠道列表正确渲染
4. 默认渠道正确选中
5. 支付流程各状态正确切换
6. 支付成功后正确返回并刷新订单详情

## 风险与注意事项

1. **时间格式处理**：后端返回 LocalDateTime，前端需转换为 Unix 时间戳
2. **模拟支付延迟**：使用 `DispatchQueue.main.asyncAfter` 实现
3. **页面刷新**：支付成功后需触发 `AppGlobalState.needRefresh = true`
4. **超时处理**：支付过程中超时需要特殊处理（可能需要取消支付）