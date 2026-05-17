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
        data = try? container.decode(Model.self, forKey: .data)
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
    var buildConfigCode: String
    var createTime: Date?
    var modifyTime: Date?
    
    var displayName: String?
    var saleModelConfigs: [SaleModelConfigItem]
    var saleModelImages: [String]
    var saleModelDesc: String
    var totalPrice: Decimal
    var isValid: Bool
}

/// 销售车型配置项
struct SaleModelConfigItem: Codable {
    var familyCode: String
    var familyName: String
    var featureCode: String
    var featureName: String
    var featurePrice: Decimal
    var featureImages: [String]?
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
    var orderTime: Int64?
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
 * 预签名上传地址
 */
struct PreSignedUrl: Codable {
    var uploadUrl: String
    var objectKey: String
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
        
        if let timestamp = try? container.decode(Int64.self, forKey: .expireTime) {
            expireTime = Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
        } else if let dateString = try? container.decode(String.self, forKey: .expireTime) {
            let formatter = ISO8601DateFormatter()
            expireTime = formatter.date(from: dateString) ?? Date()
        } else {
            expireTime = Date()
        }
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
        
        if let timestamp = try? container.decode(Int64.self, forKey: .expireTime) {
            expireTime = Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
        } else if let dateString = try? container.decode(String.self, forKey: .expireTime) {
            let formatter = ISO8601DateFormatter()
            expireTime = formatter.date(from: dateString) ?? Date()
        } else {
            expireTime = Date()
        }
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
}

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
