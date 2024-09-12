//
//  TspApi.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation
import UIKit

/// TSP接口
class TspApi {
    
    /// Mock状态
    static private var isMock = true
    
    /// 发送手机号登录验证码
    static func sendMobileVerifyCode(countryRegionCode: String, mobile: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/account/mp/login/sendVerifyCode", parameters: ["countryRegionCode": countryRegionCode, "mobile": mobile]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completion(.success(TspResponse.init(code: 0, ts: Int64(Date().timeIntervalSince1970*1000))))
            }
        }
    }
    
    /// 手机号验证码登录
    static func mobileVerifyCodeLogin(countryRegionCode: String, mobile: String, verifyCode: String, completion: @escaping (Result<TspResponse<LoginResponse>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/account/mp/login/verifyCodeLogin", parameters: ["countryRegionCode": countryRegionCode, "mobile": mobile, "verifyCode": verifyCode]) { (result: Result<TspResponse<LoginResponse>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let res = LoginResponse.init(
                    mobile: "13000000000",
                    nickname: "hwyz_leo",
                    avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663",
                    token: "token12345678",
                    tokenExpires: Int64(Date().timeIntervalSince1970*1000+24*60*60*1000),
                    refreshToken: "refreshToken12345678",
                    refreshTokenExpires: Int64(Date().timeIntervalSince1970*1000+24*60*60*1000)
                )
                completion(.success(TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: res)))
            }
        }
    }
    
    /// 获取账号信息
    static func getAccountInfo(completion: @escaping (Result<TspResponse<AccountInfo>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestGet(path: "/account/mp/account/info", parameters: [:]) { (result: Result<TspResponse<AccountInfo>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let data = AccountInfo.init(
                    mobile: "13917288107",
                    nickname: "hwyz_leo",
                    avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663",
                    gender: "MALE",
                    birthday: "1982-10-13",
                    area: "上海 长宁"
                )
                let res = TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: data)
                debugPrint("Mock API[getAccountInfo] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 生成头像预上传地址
    static func generateAvatarUrl(completion: @escaping (Result<TspResponse<PreSignedUrl>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/account/mp/account/action/generateAvatarUrl", parameters: [:]) { (result: Result<TspResponse<PreSignedUrl>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let res = PreSignedUrl.init(
                    uploadUrl: "http://xxxxxx",
                    objectKey: "xxxx"
                )
                completion(.success(TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: res)))
            }
        }
    }
    
    /// 修改头像
    static func modifyAvatar(imageUrl: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/account/mp/account/action/modifyAvatar", parameters: ["avatar":imageUrl]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completion(.success(TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000))))
            }
        }
    }
    
    /// 修改昵称
    static func modifyNickname(nickname: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/account/mp/account/action/modifyNickname", parameters: ["nickname": nickname]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let res = TspResponse<NoReply>(code: 0, ts: Int64(Date().timeIntervalSince1970*1000))
                debugPrint("Mock API[modifyNickname] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 修改性别
    static func modifyGender(gender: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/account/mp/account/action/modifyGender", parameters: ["gender": gender]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let res = TspResponse<NoReply>(code: 0, ts: Int64(Date().timeIntervalSince1970*1000))
                debugPrint("Mock API[modifyGender] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 修改生日
    static func modifyBirthday(birthday: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/account/mp/account/action/modifyBirthday", parameters: ["birthday": birthday]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let res = TspResponse<NoReply>(code: 0, ts: Int64(Date().timeIntervalSince1970*1000))
                debugPrint("Mock API[modifyBirthday] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 修改地区
    static func modifyArea(area: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/account/mp/account/action/modifyArea", parameters: ["area": area]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let res = TspResponse<NoReply>(code: 0, ts: Int64(Date().timeIntervalSince1970*1000))
                debugPrint("Mock API[modifyArea] Response")
                completion(.success(res))
            }
        }
    }
    
    // 上传COS
    static func uploadCos(url: String, image: UIImage, objectKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        if(!isMock) {
            BaseApi.uploadCos(url: url, image: image, parameters: ["key":objectKey]) { (result: Result<String, Error>) in
                completion(result)
            }
        }
    }
    
    /// 获取内容块
    static func getContentBlock(channel: String, completion: @escaping (Result<TspResponse<Array<ContentBlock>>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestGet(path: "/account/mp/account/info", parameters: [:]) { (result: Result<TspResponse<Array<ContentBlock>>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                var data: [ContentBlock] = []
                var carousels: [BaseContent] = []
                carousels.append(BaseContent.init(id: "1", type: "article", title: "尽享雪地之美", intro: "", images: ["https://pic.imgdb.cn/item/65df049a9f345e8d031861c3.png"], ts: 1709114457603))
                carousels.append(BaseContent.init(id: "2", type: "", title: "露营最佳伴侣", intro: "", images: ["https://pic.imgdb.cn/item/65df12989f345e8d033afff7.png"], ts: 1709114457603))
                carousels.append(BaseContent.init(id: "3", type: "subject", title: "一张图了解开源汽车", intro: "", images: ["https://pic.imgdb.cn/item/65df13639f345e8d033d11fb.png"], ts: 1709114457603))
                carousels.append(BaseContent.init(id: "4", type: "", title: "霸气尽显", intro: "", images: ["https://pic.imgdb.cn/item/65df13699f345e8d033d24f6.png"], ts: 1709114457603))
                data.append(ContentBlock.init(id: "1", type: "carousel", data: carousels))
                var navigations: [BaseContent] = []
                navigations.append(BaseContent.init(id: "1", type: "topic", title: "最新活动", images: ["https://pic.imgdb.cn/item/65df202d9f345e8d03619d29.png"], ts: 1709121879408))
                navigations.append(BaseContent.init(id: "2", type: "article", title: "预约试驾", images: ["https://pic.imgdb.cn/item/65df254c9f345e8d0372105c.png"], ts: 1709122924212))
                navigations.append(BaseContent.init(id: "3", type: "subject", title: "产品解读", images: ["https://pic.imgdb.cn/item/65df27319f345e8d03780cb0.png"], ts: 1709123418329))
                data.append(ContentBlock.init(id: "2", type: "navigation", data: navigations))
                var article: [BaseContent] = []
                article.append(BaseContent.init(
                    id: "1", type: "article", title: "开源汽车——旅途的最佳伴侣!",
                    intro: "趁春节假期，一家四口回了趟四川老家，途径乐山、石棉、泸定、康定、宜宾等地，总……",
                    images: [
                        "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
                        "https://pic.imgdb.cn/item/65e0201e9f345e8d03620461.png",
                        "https://pic.imgdb.cn/item/65df4e159f345e8d0301a944.png",
                        "https://pic.imgdb.cn/item/65df55069f345e8d0318a51c.png"
                    ],
                    ts: 1709124212841, username: "hwyz_leo",
                    avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663",
                    location: "万达广场",
                    commentCount: 3,
                    likeCount: 13
                ))
                data.append(ContentBlock.init(id: "3", type: "article", data: article))
                var topics: [BaseContent] = []
                topics.append(BaseContent.init(id: "1", type: "article", title: "首批车主用车心声", images: ["https://pic.imgdb.cn/item/65e012a79f345e8d03444608.png"], ts: 1709182971760))
                topics.append(BaseContent.init(id: "2", type: "article", title: "沉浸式露营", images: ["https://pic.imgdb.cn/item/65df12989f345e8d033afff7.png"], ts: 1709182971760))
                topics.append(BaseContent.init(id: "3", type: "article", title: "内饰揭秘", images: ["https://pic.imgdb.cn/item/65df13639f345e8d033d11fb.png"], ts: 1709182971760))
                topics.append(BaseContent.init(id: "4", type: "article", title: "城市穿越", images: ["https://pic.imgdb.cn/item/65df13699f345e8d033d24f6.png"], ts: 1709182971760))
                data.append(ContentBlock.init(id: "4", type: "topic", title: "北境之旅，开源出发", data: topics))
                data.append(ContentBlock.init(id: "5", type: "article", data: article))
                let res = TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: data)
                debugPrint("Mock API[getContentBlock] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 获取文章
    static func getArticle(id: String, completion: @escaping (Result<TspResponse<Article>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestGet(path: "/account/mp/account/info", parameters: [:]) { (result: Result<TspResponse<Article>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let data: Article = mockArticle()
                let res = TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: data)
                debugPrint("Mock API[getArticle] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 获取话题
    static func getSubject(id: String, completion: @escaping (Result<TspResponse<Subject>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestGet(path: "/account/mp/account/info", parameters: [:]) { (result: Result<TspResponse<Subject>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let data: Subject = Subject.init(
                    id: "1",
                    title: "旅途的最佳伴侣！",
                    image: "https://pic.imgdb.cn/item/65df13699f345e8d033d24f6.png",
                    userCount: 23,
                    articleCount: 55,
                    defaultContent: [
                        BaseContent.init(id: "1", type: "article", title: "开启露营模式！", intro: "开着汽车，带着家人，帐篷打开，气炉点燃。热腾腾的粥，香喷喷的米饭。", images: [
                            "https://pic.imgdb.cn/item/65e17d2b9f345e8d038aab68.png",
                            "https://pic.imgdb.cn/item/65e17d549f345e8d038b84aa.png"
                        ], ts: 1709275436479, username: "夜月", location: "上海市"),
                        BaseContent.init(id: "2", type: "article", title: "燃行冬日，立即出发！", intro: "时光跌跌撞撞，季节来来往往", images: [
                            "https://pic.imgdb.cn/item/65df12989f345e8d033afff7.png"
                        ], ts: 1709275436479, username: "越野爱好者", location: "山东省")
                    ],
                    latestContent: [
                        BaseContent.init(id: "1", type: "article", title: "带我去看冬日的春意", intro: "第一次开着汽车带着家人走山道，选了一个好的不能再好的天气去附近的百花山露营", images: [
                            "https://pic.imgdb.cn/item/65e17e9a9f345e8d038f171a.png",
                            "https://pic.imgdb.cn/item/65e17ea99f345e8d038f3c9a.png"
                        ], ts: 1709275436479, username: "Alle22", location: "青海省"),
                        BaseContent.init(id: "2", type: "article", title: "黎族山区自驾", intro: "黎族山区", images: [
                            "https://pic.imgdb.cn/item/65df27319f345e8d03780cb0.png"
                        ], ts: 1709275436479, username: "旅游达人", location: "河南省")
                    ]
                )
                let res = TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: data)
                debugPrint("Mock API[getSubject] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 获取专题
    static func getTopic(id: String, completion: @escaping (Result<TspResponse<Topic>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestGet(path: "/account/mp/account/info", parameters: [:]) { (result: Result<TspResponse<Topic>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let data: Topic = Topic.init(
                    id: "1",
                    title: "产品解读",
                    image: "https://pic.imgdb.cn/item/65df4e159f345e8d0301a944.png",
                    contents: [
                        BaseContent.init(id: "1", type: "article", title: "智能穿越助你探索山西", images: ["https://pic.imgdb.cn/item/65e012a79f345e8d03444608.png"], ts: 1709284625762, username: "hwyz_leo", avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663"),
                        BaseContent.init(id: "2", type: "article", title: "户外露营生活新选择", images: ["https://pic.imgdb.cn/item/65df3bb89f345e8d03c2306c.png"], ts: 1709284625762, username: "山高第九"),
                        BaseContent.init(id: "3", type: "article", title: "一键舒享的航空座椅", images: ["https://pic.imgdb.cn/item/65df13639f345e8d033d11fb.png"], ts: 1709284625762, username: "一起探索")
                    ]
                )
                let res = TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: data)
                debugPrint("Mock API[getTopic] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 点赞文章
    static func likeArticle(id: String, liked: Bool, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/account/mp/account/action/modifyBirthday", parameters: ["id": id]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let res = TspResponse<NoReply>(code: 0, ts: Int64(Date().timeIntervalSince1970*1000))
                debugPrint("Mock API[likeArticle] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 获取爱车首页
    static func getVehicleIndex(completion: @escaping (Result<TspResponse<VehicleIndex>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestGet(path: "/account/mp/account/info", parameters: [:]) { (result: Result<TspResponse<VehicleIndex>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                var data: VehicleIndex =  mockVehicleIndex()
                let res = TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: data)
                debugPrint("Mock API[getVehicleIndex] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 解锁车辆
    static func unlockVehicle(completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/unlockVehicle", parameters: [:]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let res = TspResponse<NoReply>(code: 0, ts: Date().timestamp())
                debugPrint("Mock HTTP API[unlockVehicle] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 上锁车辆
    static func lockVehicle(completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/lockVehicle", parameters: [:]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let res = TspResponse<NoReply>(code: 0, ts: Date().timestamp())
                debugPrint("Mock HTTP API[lockVehicle] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 设置车窗
    static func setWindow(percent: Int, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/setWindow", parameters: [:]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let res = TspResponse<NoReply>(code: 0, ts: Date().timestamp())
                debugPrint("Mock HTTP API[setWindow] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 设置尾门
    static func setTrunk(percent: Int, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestPost(path: "/setTrunk", parameters: [:]) { (result: Result<TspResponse<NoReply>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let res = TspResponse<NoReply>(code: 0, ts: Date().timestamp())
                debugPrint("Mock HTTP API[setTrunk] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 寻车
    static func findVehicle(vin: String, completion: @escaping (Result<TspResponse<RemoteControlState>, Error>) -> Void) {
        if(isMock) {
            let parameters = [
                "vin": vin
            ]
            BaseApi.requestPost(path: "/mp/rvc/action/findVehicle", parameters: parameters) { (result: Result<TspResponse<RemoteControlState>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let res = TspResponse<RemoteControlState>(code: 0, ts: Date().timestamp())
                debugPrint("Mock HTTP API[findVehicle] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 获取商城首页
    static func getMallIndex(completion: @escaping (Result<TspResponse<MallIndex>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestGet(path: "/account/mp/account/info", parameters: [:]) { (result: Result<TspResponse<MallIndex>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let data: MallIndex = mockMallIndex()
                let res = TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: data)
                debugPrint("Mock API[getMallIndex] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 获取商品
    static func getProduct(id: String, completion: @escaping (Result<TspResponse<Product>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestGet(path: "/account/mp/account/info", parameters: [:]) { (result: Result<TspResponse<Product>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let data: Product = mockProduct()
                let res = TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: data)
                debugPrint("Mock API[getProdct] Response")
                completion(.success(res))
            }
        }
    }
    
    /// 购买商品确认
    static func buyProductConfirm(id: String, buyCount: Int, completion: @escaping (Result<TspResponse<ProductOrder>, Error>) -> Void) {
        if(!isMock) {
            BaseApi.requestGet(path: "/account/mp/account/info", parameters: [:]) { (result: Result<TspResponse<ProductOrder>, Error>) in
                completion(result)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let data: ProductOrder = mockProductOrder()
                let res = TspResponse(code: 0, ts: Int64(Date().timeIntervalSince1970*1000), data: data)
                debugPrint("Mock API[buyProductConfirm] Response")
                completion(.success(res))
            }
        }
    }
    
}
