//
//  HttpBean.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

/**
 * TSP平台通用响应实体
 */
struct TspResponse<Model: Codable>: Codable {
    var code: Int
    var message: String?
    var ts: Int64
    var data: Model?
}

/**
 * 无响应内容
 */
struct NoReply: Codable {}

/**
 * 登录响应
 */
struct LoginResponse: Codable {
    var mobile: String
    var nickname: String
    var avatar: String
    var token: String
    var tokenExpires: Int64
    var refreshToken: String
    var refreshTokenExpires: Int64
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
