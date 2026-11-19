//
//  HttpBean.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

struct AnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let arrayValue = value as? [Any] {
            try container.encode(arrayValue.map { AnyCodable(value: $0) })
        } else if let dictValue = value as? [String: Any] {
            try container.encode(dictValue.mapValues { AnyCodable(value: $0) })
        } else {
            try container.encode("")
        }
    }
    
    init(value: Any) {
        self.value = value
    }
}

/// TSP平台通用响应实体
struct TspResponse<Model: Codable>: Codable {
    var code: String
    var message: String?
    var ts: Int64
    var data: Model?
    var traceId: String?
    var timestamp: Int64

    enum CodingKeys: String, CodingKey {
        case code, message, ts, data, traceId, timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringCode = try? container.decode(String.self, forKey: .code) {
            code = stringCode
        } else if let intCode = try? container.decode(Int.self, forKey: .code) {
            code = String(intCode)
        } else {
            code = ""
        }
        message = try? container.decode(String.self, forKey: .message)
        ts = (try? container.decode(Int64.self, forKey: .ts)) ?? 0
        // 注意：原来用 `try?` 直接吞掉内层模型的解码错误，导致“HTTP 200 但 data 为 nil”，
        // 调用方只能看到“请求异常”而无法定位字段问题。这里保留 nil 语义，但把错误打出来。
        do {
            data = try container.decodeIfPresent(Model.self, forKey: .data)
        } catch {
            data = nil
            SafeLog.log("⚠️ TspResponse.data 解码失败（已按 nil 处理）:", String(describing: error))
        }
        traceId = try? container.decode(String.self, forKey: .traceId)
        timestamp = (try? container.decode(Int64.self, forKey: .timestamp)) ?? 0
    }

    init(code: String = "", message: String? = nil, ts: Int64 = 0, data: Model? = nil, traceId: String? = nil, timestamp: Int64 = 0) {
        self.code = code
        self.message = message
        self.ts = ts
        self.data = data
        self.traceId = traceId
        self.timestamp = timestamp
    }

    var isSuccess: Bool {
        return code == "000000"
    }
}

/// 无响应内容
struct NoReply: Codable {}

/// 登录响应
struct LoginResponse: Codable {
    var userId: String
    var newUser: Bool
    var sessionId: String?
    var challengeRequired: Bool?
    var captchaChallenge: String?
    var fallbackRequired: Bool?
    var accessToken: String?
    var accessTokenTtl: Int64?
    var refreshToken: String?
    var mobile: String?
    var nickname: String?
    var avatar: String?
    var followingCount: Int?
    var followerCount: Int?
    var postCount: Int?
    var collectionCount: Int?
    var unreadMsgCount: Int?
    var latestMsgTitle: String?

    var token: String? {
        return accessToken
    }

    var tokenExpires: Int64? {
        guard let ttl = accessTokenTtl else { return nil }
        return Int64(Date().timeIntervalSince1970 * 1000) + ttl * 1000
    }
}

/// 车辆销售订单
struct VehicleSaleOrder: Codable {
    /// 订单号
    var orderNum: String
    /// 订单状态
    var orderState: Int
    /// 显示名称
    var displayName: String
}

/// 销售车型配置
struct SaleModelConfig: Codable, Hashable {
    /// 销售代码
    var saleCode: String
    /// 销售车型配置类型
    var type: String
    /// 销售车型配置类型代码
    var typeCode: String
    /// 销售车型配置类型名称
    var typeName: String
    /// 销售车型配置类型价格
    var typePrice: Decimal
    /// 销售车型配置类型图片
    var typeImage: [String]
    /// 销售车型配置类型描述
    var typeDesc: String?
    /// 销售车型配置类型参数
    var typeParam: String?
}

/// 特征值详细信息
struct FeatureCodeDetailVo: Codable, Hashable {
    /// 特征值编码
    var featureCode: String
    /// 特征值名称
    var featureName: String
    /// 特征值价格
    var featurePrice: Decimal
    /// 特征值图片列表
    var featureImage: [String]
    /// 特征值描述
    var featureDesc: String?
    /// 特征值参数
    var featureParam: String?
    /// 是否启用
    var enable: Bool
    /// 排序
    var sort: Int
}

/// 特征值范围（特征族）
struct FeatureCodeRangeVo: Codable, Hashable {
    /// 特征族编码
    var familyCode: String
    /// 特征族名称
    var familyName: String
    /// 特征族价格
    var familyPrice: Decimal
    /// 特征族图片列表
    var familyImage: [String]
    /// 特征族描述
    var familyDesc: String?
    /// 特征族参数
    var familyParam: String?
    /// 是否启用
    var enable: Bool
    /// 排序
    var sort: Int
    /// 特征值详细信息列表
    var featureDetails: [FeatureCodeDetailVo]
}

/// 已选择的销售车型
struct SelectedSaleModel: Codable {
    /// 销售车型代码
    var saleModelCode: String
    /// 销售车型名称
    var modelName: String
    /// 是否允许意向金
    var earnestMoney: Bool
    /// 意向金价格
    var earnestMoneyPrice: Decimal
    /// 是否允许定金
    var downPayment: Bool
    /// 定金价格
    var downPaymentPrice: Decimal
    /// 生产配置代码
    var buildConfigCode: String
    /// 销售车型配置类型
    var saleModelConfigType: [String:String]
    /// 销售车型图片集
    var saleModelImages: [String]
    /// 销售车型描述
    var saleModelDesc: String
    /// 销售车型配置名称
    var saleModelConfigName: [String:String]
    /// 销售车型配置价格
    var saleModelConfigPrice: [String:Decimal]
    /// 车型总价格
    var totalPrice: Decimal
    /// 购车权益简介
    var purchaseBenefitsIntro: String
}

/// 我的车辆（合并心愿单和订单）
/// 用于首页列表展示，包含缩略信息
struct MyVehicleVo: Codable {
    var id: String
    var type: String
    var displayName: String?
    var state: Int
    var saleModelImages: [String]?
    var totalPrice: Decimal?
    var saleModelDesc: String?
}

/// 心愿单详情
struct Wishlist: Codable {
    var wishlistId: String
    var saleModelCode: String
    var modelCode: String
    var variantCode: String
    var configurationCode: String
    var optionCodes: [String]
    var createTime: Date?
    var modifyTime: Date?
    var invalidReason: String?
    var saleModelName: String?
    var modelMarketingName: String?
    var variantMarketingName: String?
    var variantPrice: Decimal?
    var saleModelImages: [String]?
    var totalPrice: Decimal?
    var optionDetails: [OptionDetail]?
}

/// 心愿单选项详情
struct OptionDetail: Codable {
    var optionFamilyCode: String
    var optionCode: String
    var marketingTitle: String?
    var optionPrice: Decimal?
    var marketingImage: String?
}



/// 上牌区域
struct LicenseArea: Codable {
    /// 省级行政区代码
    var provinceCode: String
    /// 地区级行政区代码
    var cityCode: String?
    /// 显示名称
    var displayName: String
}

/// 销售门店
struct Dealership: Codable {
    /// 门店代码
    var code: String
    /// 门店名称
    var name: String
    /// 门店地址
    var address: String
    /// 门店距离
    var distance: Double?
}

/// 订单
struct Order: Codable {
    var saleCode: String?
    var orderNo: String
    var orderState: Int
    var saleModelCode: String?
    var saleModelConfigType: [String:String]?
    var saleModelConfigName: [String:String]?
    var saleModelConfigPrice: [String:Decimal]?
    var saleModelImages: [String]?
    var saleModelDesc: String?
    var totalPrice: Decimal?
    /// 订单时间（兼容时间戳与 ISO-8601 字符串，见 `FlexibleTimestamp`）
    @FlexibleTimestamp var orderTime: Int64?
    var customerType: String?
    var paymentMethod: String?
    var orderPersonType: Int?
    var purchasePlan: Int?
    var orderPersonName: String?
    var orderPersonIdType: Int?
    var orderPersonIdNum: String?
    var licenseCityCode: String?
    var licenseCityName: String?
    var orderStoreCode: String?
    var orderStoreName: String?
    var deliveryStoreCode: String?
    var deliveryStoreName: String?
    var dealershipCode: String?
    var dealershipName: String?
    var deliveryCenterCode: String?
    var deliveryCenterName: String?
    var modelCode: String?
    var modelName: String?
    var variantCode: String?
    var variantName: String?
    var configurationCode: String?
    var optionCodes: [String]?
    var optionBreakdown: [OptionBreakdownItem]?
    /// 尾款金额（OTD-VSO-DSN-CR-014：服务端金额快照，只读展示；缺失为 nil）
    var tailPaymentAmount: Decimal?
}

/// 选项明细项
struct OptionBreakdownItem: Codable {
    var optionCode: String
    var optionFamilyCode: String?
    var optionFamilyName: String?
    var optionName: String?
    var optionPrice: Decimal?
}

/// 订单支付响应
struct OrderPaymentResponse: Codable {
    /// 订单号
    var orderNum: String
    /// 支付商户
    var paymentMerchant: String
    /// 支付流水号
    var paymentReference: String
    /// 支付金额
    var paymentAmount: Decimal
    /// 支付数据类型
    var paymentDateType: Int
    /// 支付数据
    var paymentData: String
}

/**
 * 账号信息
 */
struct AccountInfo: Codable {
    var userId: String?
    var profileId: String?
    var nickname: String?
    var avatarUrl: String?
    var realName: String?
    var gender: Int?
    var birthday: [Int]?
    var regionCode: String?
    var regionName: String?
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case profileId
        case nickname
        case avatarUrl
        case realName
        case gender
        case birthday
        case regionCode
        case regionName
        case description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        profileId = try container.decodeIfPresent(String.self, forKey: .profileId)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        realName = try container.decodeIfPresent(String.self, forKey: .realName)
        gender = try container.decodeIfPresent(Int.self, forKey: .gender)
        regionCode = try container.decodeIfPresent(String.self, forKey: .regionCode)
        regionName = try container.decodeIfPresent(String.self, forKey: .regionName)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        
        if let birthdayString = try container.decodeIfPresent(String.self, forKey: .birthday) {
            self.birthday = parseBirthdayString(birthdayString)
        } else if let birthdayArray = try container.decodeIfPresent([Int].self, forKey: .birthday) {
            self.birthday = birthdayArray
        } else {
            self.birthday = nil
        }
    }
    
    private func parseBirthdayString(_ string: String) -> [Int]? {
        let components = string.split(separator: "-").compactMap { Int($0) }
        if components.count == 3 {
            return components
        }
        return nil
    }
}

/**
 * 账号二维码信息
 */
struct AccountQrcode: Codable {
    var qrcode: String
}

/**
 * 头像上传申请参数（IOS-APP-DSN-CR-003 §4.1 / §5.1）
 */
struct AvatarUploadRequest: Codable {
    /// 固定 avatar.jpg
    var originalFilename: String
    /// 固定 image/jpeg
    var contentType: String
    /// 实际字节数
    var size: Int
}

/**
 * 头像上传票据（IOS-APP-DSN-CR-003 §4.1 / §5.1）
 */
struct AvatarUploadTicket: Codable {
    var uploadId: String
    /// 绝对预签名地址（含 query，原值直传）
    var uploadUrl: String
    var httpMethod: String
    var contentType: String
    /// 过期时间（epoch 毫秒）
    var expiresAt: Int64
}

/**
 * 头像上传结果（IOS-APP-DSN-CR-003 §4.1 / §5.3）
 */
struct AvatarResult: Codable, Equatable {
    var avatarUrl: String
    var objectId: String
    var contentType: String
    var size: Int
}

/// 内容块
struct ContentBlock: Codable {
    var id: String
    var type: String
    var title: String?
    var data: [BaseContent]
}

/// 基础内容
struct BaseContent: Codable {
    var id: String
    var type: String
    var title: String
    var intro: String?
    var images: [String]
    var ts: Int64
    var username: String?
    var avatar: String?
    var location: String?
    var tags: [String]?
    var commentCount: Int64?
    var likeCount: Int64?
}

/// 文章
struct Article: Codable {
    var id: String
    var title: String
    var content: String
    var images: [String]
    var ts: Int64
    var username: String
    var avatar: String?
    var views: Int64
    var location: String?
    var tags: [String]
    var comments: [ArticleComment]
    var likeCount: Int64
    var liked: Bool
    var shareCount: Int64
}

/// 文章评论
struct ArticleComment: Codable {
    var id: String
    var parentId: String
    var comment: String
    var replyer: String?
    var ts: Int64
    var username: String
    var avatar: String?
    var location: String?
}

/// 主题
struct Subject: Codable {
    var id: String
    var title: String
    var content: String?
    var image: String?
    var endTs: Int64?
    var userCount: Int64
    var articleCount: Int64
    var defaultContent: [BaseContent]
    var latestContent: [BaseContent]
}

/// 专题
struct Topic: Codable {
    var id: String
    var title: String
    var content: String?
    var image: String?
    var contents: [BaseContent]
}

/// 爱车首页
struct VehicleIndex: Codable {
    var vehicle: Vehicle
}

/// 车辆
struct Vehicle: Codable {
    var vin: String
    var bodyImg: String?
    var topImg: String?
    var drivingRange: Int
    var electricDrivingRange: Int
    var electricPercentage: Int
    var fuelDrivingRange: Int
    var fuelPercentage: Int
    var interiorTemp: Int
    var flTirePressure: Float
    var flTireTemp: Int
    var frTirePressure: Float
    var frTireTemp: Int
    var rlTirePressure: Float
    var rlTireTemp: Int
    var rrTirePressure: Float
    var rrTireTemp: Int
    var lockState: Bool
    var windowPercentage: Int
    var trunkPercentage: Int
}

/// 商城首页
struct MallIndex: Codable {
    var recommendedProducts: [Product]
    var categories: [String:[Product]]
    var zones: [MallZone]?
}

/// 商城专区
struct MallZone: Codable {
    var title: String
    var subtitle: String?
    var cover: String?
    var products: [Product]
}

/// 商品
struct Product: Codable {
    var id: String
    var name: String
    var intro: String?
    var cover: String?
    var recommendedCover: String?
    var images: [String]?
    var price: Int?
    var points: Int?
}

/// 商品订单
struct ProductOrder: Codable {
    var product: Product
    var buyCount: Int
    var totalPrice: Int
    var freight: Int
    var remainingPoints: Int32
}

/// 远控状态
struct RemoteControlState: Codable {
    /// 车架号
    var vin: String
    /// 指令ID
    var cmdId: String
    /// 指令状态
    var cmdState: String
    /// 远控指令错误信息
    var failureMsg: String?
}

/// 发送手机验证码请求
struct SendMobileCodeRequest: Codable {
    var mobile: String
    var countryCode: String
}

/// 设备信息
struct DeviceInfo: Codable {
    var deviceId: String?
    var deviceType: String?
    var deviceName: String?
    var deviceOs: String?
    var appVersion: String?
    var deviceFingerprint: String?
    var language: String?
}

/// 手机验证码登录请求
struct MobileLoginRequest: Codable {
    var mobile: String
    var countryCode: String
    var code: String
    var deviceInfo: DeviceInfo?
}

/// 意向金下单结果
struct EarnestMoneyOrderResult: Codable {
    var orderNo: String
    var earnestMoneyAmount: Decimal
    var paymentChannels: [PaymentChannelInfo]
    var expireTime: Date
    
    enum CodingKeys: String, CodingKey {
        case orderNo, earnestMoneyAmount, paymentChannels, expireTime
    }
    
    init(orderNo: String, earnestMoneyAmount: Decimal, paymentChannels: [PaymentChannelInfo], expireTime: Date) {
        self.orderNo = orderNo
        self.earnestMoneyAmount = earnestMoneyAmount
        self.paymentChannels = paymentChannels
        self.expireTime = expireTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderNo = try container.decode(String.self, forKey: .orderNo)
        earnestMoneyAmount = try container.decode(Decimal.self, forKey: .earnestMoneyAmount)
        paymentChannels = try container.decode([PaymentChannelInfo].self, forKey: .paymentChannels)
        expireTime = decodePaymentExpireTime(from: container,
                                             key: .expireTime,
                                             payload: "EarnestMoneyOrderResult")
    }
}

/// 定金下单结果
struct DownPaymentOrderResult: Codable {
    var orderNo: String?
    var downPaymentAmount: Decimal
    var paymentChannels: [PaymentChannelInfo]
    var expireTime: Date
    
    enum CodingKeys: String, CodingKey {
        case orderNo, downPaymentAmount, paymentChannels, expireTime
    }
    
    init(orderNo: String?, downPaymentAmount: Decimal, paymentChannels: [PaymentChannelInfo], expireTime: Date) {
        self.orderNo = orderNo
        self.downPaymentAmount = downPaymentAmount
        self.paymentChannels = paymentChannels
        self.expireTime = expireTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderNo = try? container.decode(String.self, forKey: .orderNo)
        downPaymentAmount = try container.decode(Decimal.self, forKey: .downPaymentAmount)
        paymentChannels = try container.decode([PaymentChannelInfo].self, forKey: .paymentChannels)
        expireTime = decodePaymentExpireTime(from: container,
                                             key: .expireTime,
                                             payload: "DownPaymentOrderResult")
    }
}

/// 支付截止时间解码
///
/// 后端时间契约已统一为 ISO-8601（`Instant` 会带 0~9 位小数秒，如
/// `2026-11-13T06:25:40.506874710Z`），同时需兼容历史 epoch 毫秒/秒与数字字符串。
///
/// 关键：**解析失败不能退化成 `Date()`（=此刻）**——那会让支付页一进入就渲染
/// 「支付已超时」并把「立即支付」置灰，等于把“契约解析失败”伪装成“订单已过期”。
/// 这里回退为「当前时间 + 默认支付窗口」，页面仍可发起支付，真实过期以服务端
/// 201057（订单已失效）为准，由 PaymentFlowService 自动恢复。
private enum PaymentExpireTimeFallback {
    /// 与服务端小订单默认支付窗口一致（30 分钟中取较保守的 15 分钟）
    static let seconds: TimeInterval = 900
}

private func decodePaymentExpireTime<K: CodingKey>(from container: KeyedDecodingContainer<K>,
                                                    key: K,
                                                    payload: String) -> Date {
    if let parsed = container.decodePaymentExpireTime(forKey: key) {
        return parsed
    }
    SafeLog.log("⚠️ \(payload).expireTime 缺失或格式无法识别，回退默认支付窗口 \(Int(PaymentExpireTimeFallback.seconds))s")
    return Date().addingTimeInterval(PaymentExpireTimeFallback.seconds)
}

private extension KeyedDecodingContainer {
    /// 兼容 epoch 毫秒/秒、数字字符串、ISO-8601（含 0~9 位小数秒，`Z` 或 `+08:00` 偏移）
    func decodePaymentExpireTime(forKey key: Key) -> Date? {
        if let value = try? decodeIfPresent(Double.self, forKey: key) {
            return TspManager.date(fromEpochNumber: value)
        }
        if let text = try? decodeIfPresent(String.self, forKey: key) {
            return TspManager.parseTimestamp(from: text)
        }
        return nil
    }
}

/// 支付渠道信息
struct PaymentChannelInfo: Codable, Identifiable {
    var channelCode: String
    var channelName: String
    var isDefault: Bool
    
    var id: String { channelCode }
    
    enum CodingKeys: String, CodingKey {
        case channelCode, channelName, isDefault
    }
}

/// 发起支付结果
struct InitiatePaymentResult: Codable {
    var paymentNo: String
    var paymentChannel: String
    var paymentAmount: Decimal
    var paymentMerchant: String?
    var paymentReference: String?
    /// 支付状态（PENDING_PAYMENT/PROCESSING/PAID/PAYMENT_FAILED/CANCELLED/CLOSED）
    var paymentStatus: String?
    /// 外部交易单号
    var externalTradeNo: String?
    /// 支付阶段（OTD-VSO-DSN-CR-014：尾款返回 TAIL_PAYMENT）
    var paymentStage: String?
    /// 支付截止时间（epoch millis）
    @FlexibleTimestamp var expireTime: Int64?
}

/// 重新发起支付结果（OTD-VSO-DSN-CR-005）
struct ReopenPaymentResult: Codable {
    /// 订单号
    var orderNo: String
    /// 恢复后的订单状态（EARNEST_MONEY_UNPAID = 200）
    var orderState: Int
    /// 已使用的恢复次数（最多 2 次）
    var reopenCount: Int
    /// 本次支付窗口截止时间（epoch 毫秒，兼容字符串/ISO-8601）
    @FlexibleTimestamp var expireTime: Int64?
}

/// 支付单查询结果
struct PaymentRecord: Codable, Identifiable {
    var paymentNo: String
    var orderNo: String?
    var paymentStage: String?
    var paymentChannel: String?
    var paymentAmount: Decimal?
    var paymentStatus: String?
    var externalTradeNo: String?
    /// 支付时间（epoch millis）
    @FlexibleTimestamp var payTime: Int64?
    /// 支付截止时间（epoch millis）
    @FlexibleTimestamp var expireTime: Int64?
    var failReason: String?

    var id: String { paymentNo }
}

/// 购车合同（OTD-VSO-DSN-CR-014）
///
/// 发起签署与查询合同共用；发起响应是查询响应的子集，缺失字段为 nil。
struct ContractInfo: Codable {
    var contractNo: String?
    var contractType: String?
    /// DRAFT / GENERATED / SIGNING / SIGNED / EFFECTIVE / INVALID
    var contractStatus: String?
    var signNo: String?
    /// 签署地址（仅 SIGNING 时返回；Mock 为 mock://，不可直接加载）
    var signUrl: String?
    var fileUrl: String?
    /// 生成时间（epoch millis）
    @FlexibleTimestamp var generateTime: Int64?
    /// 签署时间（epoch millis）
    @FlexibleTimestamp var signTime: Int64?
    /// 生效时间（epoch millis）
    @FlexibleTimestamp var effectiveTime: Int64?
    /// 失效时间（epoch millis）
    @FlexibleTimestamp var invalidTime: Int64?
    var invalidReason: String?

    /// 是否已签署到可用于尾款门槛的状态（SIGNED / EFFECTIVE）
    var isSignEffective: Bool {
        contractStatus == "SIGNED" || contractStatus == "EFFECTIVE"
    }

    /// 是否签署中
    var isSigning: Bool {
        contractStatus == "SIGNING"
    }
}

/// 购车协议
struct PurchaseAgreement: Codable, Identifiable {
    var agreementId: String?
    var agreementCode: String
    var saleModelCode: String?
    var versionNo: Int
    var title: String?
    var intro: String?
    var detail: String?
    var agreementStatus: String?
    /// 生效开始时间（epoch millis）
    @FlexibleTimestamp var effectiveFrom: Int64?
    /// 生效结束时间（epoch millis）
    @FlexibleTimestamp var effectiveTo: Int64?

    var id: String { agreementId ?? "\(agreementCode)_\(versionNo)" }
}

/// 购车协议确认参数
struct AgreementConfirmation: Codable {
    var agreementCode: String
    var versionNo: Int
}

/// 订单时间线事件
struct OrderTimelineEvent: Codable, Identifiable {
    var eventType: String
    var eventName: String?
    /// 事件时间（epoch millis）
    @FlexibleTimestamp var eventTime: Int64?
    var beforeStatus: String?
    var afterStatus: String?
    var operatorId: String?
    var operatorRole: String?
    var operateSource: String?
    var relatedDocNo: String?
    var result: String?
    var failReason: String?
    var eventRemark: String?

    var id: String { "\(eventType)_\(eventTime ?? 0)_\(relatedDocNo ?? "")" }
}

/// 意向金转定金结果
struct EarnestToDownResponse: Codable {
    var orderNo: String?
    var orderType: String?
    var orderState: String?
    var supplementaryPayment: SupplementaryPayment?
}

/// 补款任务
struct SupplementaryPayment: Codable {
    var supplementaryNo: String?
    var amount: Decimal?
    var currency: String?
    /// 补款截止时间（epoch millis）
    @FlexibleTimestamp var expireTime: Int64?
}

/// 销售车型（手机端）
struct SaleModelMp: Codable, Identifiable {
    /// 销售车型代码
    var saleModelCode: String
    /// Carline 编码
    var carlineCode: String?
    /// Carline 名称
    var carlineName: String?
    /// 销售车型名称
    var modelName: String
    /// 起售价
    var startingPrice: Decimal?
    /// 意向金价格
    var earnestMoneyPrice: Decimal?
    /// 销售车型图片集
    var images: [String]?
    /// 卖点文案
    var marketingCopy: String?
    /// 车型图标
    var icon: String?
    /// 排序权重
    var sortWeight: Int?
    
    var id: String { saleModelCode }
    
    /// 兼容旧逻辑：是否允许意向金
    var earnestMoney: Bool { earnestMoneyPrice != nil && earnestMoneyPrice! > 0 }
    /// 兼容旧逻辑：是否允许定金（新接口暂无此字段，默认false）
    var downPayment: Bool { false }
    /// 兼容旧逻辑：定金价格（新接口暂无此字段，默认0）
    var downPaymentPrice: Decimal { 0 }
}

/// 选配器数据结果
struct ConfiguratorResult: Codable {
    /// 销售车型编码
    var saleModelCode: String
    /// 销售车型名称
    var modelName: String
    /// 三段式结构：Model → Variant → Option
    var models: [ModelItem]
    
    struct ModelItem: Codable {
        var modelCode: String
        var modelName: String
        var marketingImage: String?
        var marketingCopy: String?
        var sortWeight: Int?
        var variants: [VariantItem]
    }
    
    struct VariantItem: Codable {
        var variantCode: String
        var variantName: String
        var marketingImage: String?
        var marketingCopy: String?
        var sortWeight: Int?
        var variantPrice: Decimal
        var earnestMoneyPrice: Decimal?
        var downPaymentPrice: Decimal?
        var selectableFamilies: [SelectableFamily]
    }
    
    struct SelectableFamily: Codable {
        var optionFamilyCode: String
        var optionFamilyName: String
        var marketingImage: String?
        var marketingDesc: String?
        var sortWeight: Int?
        var options: [OptionItem]
    }
    
    struct OptionItem: Codable {
        var optionCode: String
        var optionName: String
        var saleStatus: String
        var price: Decimal
        var image: String?
        var marketingCopy: String?
        var bundleWith: [String]?
        var mutexWith: [String]?
    }
}

/// 实时报价结果
struct QuoteResult: Codable {
    /// Configuration 编码
    var configurationCode: String
    /// Variant 价格
    var variantPrice: Decimal
    /// Option 总价
    var optionTotalPrice: Decimal
    /// 总价 = variantPrice + optionTotalPrice
    var totalPrice: Decimal
    /// Option 价格明细
    var optionBreakdown: [OptionPriceItem]
    
    struct OptionPriceItem: Codable {
        var optionFamilyCode: String?
        var optionCode: String
        var optionPrice: Decimal
    }
}

/// 获取实时报价请求参数
struct GetQuoteCmd: Codable {
    /// 销售车型编码
    var saleModelCode: String
    /// Model 编码
    var modelCode: String
    /// Variant 编码
    var variantCode: String
    /// OptionCode 列表
    var optionCodes: [String]
    /// 区域编码
    var regionCode: String
}
