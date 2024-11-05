//
//  HttpBean.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

/// TSP平台通用响应实体
struct TspResponse<Model: Codable>: Codable {
    var code: Int
    var message: String?
    var ts: Int64
    var data: Model?
}

/// 无响应内容
struct NoReply: Codable {}

/// 登录响应
struct LoginResponse: Codable {
    var mobile: String
    var nickname: String
    var avatar: String
    var token: String
    var tokenExpires: Int64
    var refreshToken: String
    var refreshTokenExpires: Int64
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
    var typeDesc: String
    /// 销售车型配置类型参数
    var typeParam: String
}

/// 已选择的销售车型
struct SelectedSaleModel: Codable {
    /// 销售代码
    var saleCode: String
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
    /// 车型配置代码
    var modelConfigCode: String
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

/// 心愿单
struct Wishlist: Codable {
    /// 销售代码
    var saleCode: String
    /// 订单号
    var orderNum: String
    /// 销售车型配置类型
    var saleModelConfigType: [String:String]
    /// 销售车型配置名称
    var saleModelConfigName: [String:String]
    /// 销售车型配置价格
    var saleModelConfigPrice: [String:Decimal]
    /// 销售车型图片集
    var saleModelImages: [String]
    /// 销售车型描述
    var saleModelDesc: String
    /// 总价格
    var totalPrice: Decimal
    /// 是否有效
    var isValid: Bool
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
    /// 销售代码
    var saleCode: String?
    /// 订单号
    var orderNum: String
    /// 订单状态
    var orderState: Int
    /// 销售车型配置类型
    var saleModelConfigType: [String:String]
    /// 销售车型配置名称
    var saleModelConfigName: [String:String]
    /// 销售车型配置价格
    var saleModelConfigPrice: [String:Decimal]
    /// 销售车型图片集
    var saleModelImages: [String]
    /// 销售车型描述
    var saleModelDesc: String
    /// 总价格
    var totalPrice: Decimal
    /// 下单时间
    var orderTime: Int64
    /// 下单人类型
    var orderPersonType: Int?
    /// 购车方案
    var purchasePlan: Int?
    /// 下单人名称
    var orderPersonName: String?
    /// 下单人证件类型
    var orderPersonIdType: Int?
    /// 下单人证件号
    var orderPersonIdNum: String?
    /// 上牌城市代码
    var licenseCityCode: String?
    /// 销售门店代码
    var dealershipCode: String?
    /// 交付中心代码
    var deliveryCenterCode: String?
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
    var mobile: String
    var nickname: String
    var avatar: String?
    var gender: String
    var birthday: String?
    var area: String?
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
