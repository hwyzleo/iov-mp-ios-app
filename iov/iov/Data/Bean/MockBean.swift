//
//  MockBean.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

/// 登录信息
func mockLoginResponse() -> LoginResponse {
    return LoginResponse.init(
        mobile: "13917288107",
        nickname: "hwyz_leo",
        avatar: "https://pic.imgdb.cn/item/66e667a0d9c307b7e93075e8.png",
        token: "zgZA0dO9gTbhSb6PDBXCb_0mxFq-q33Uo81aNC4hT_hpPvwxJhQASovI0zGlw58K",
        tokenExpires: Int64(Date().timeIntervalSince1970*1000+24*60*60*1000),
        refreshToken: "rWtoZhVVf6mZW-t1hhqkNazR0r92KkhxDItf05jfQYChT6SrnFi2IXaXD02irjVc",
        refreshTokenExpires: Int64(Date().timeIntervalSince1970*1000+24*60*60*1000)
    )
}

/// 销售车型
func mockSaleModelResponse() -> SaleModelResponse {
    return SaleModelResponse.init(saleModels: [
        SaleModel.init(saleCode: "H01", saleModelType: "OPTIONAL", saleModelTypeCode: "X02", saleName: "高阶智驾", salePrice: 3000, saleImage: "", saleDesc: "", saleParam: ""),
        SaleModel.init(saleCode: "H01", saleModelType: "OPTIONAL", saleModelTypeCode: "X00", saleName: "标准智驾", salePrice: 0, saleImage: "", saleDesc: "", saleParam: ""),
        SaleModel.init(saleCode: "H01", saleModelType: "INTERIOR", saleModelTypeCode: "NS03", saleName: "霜雪白内饰", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png", saleDesc: "", saleParam: "#dcdcd6"),
        SaleModel.init(saleCode: "H01", saleModelType: "INTERIOR", saleModelTypeCode: "NS02", saleName: "珊瑚橙内饰", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/670687ecd29ded1a8cbb5280.png", saleDesc: "", saleParam: "#a35d31"),
        SaleModel.init(saleCode: "H01", saleModelType: "INTERIOR", saleModelTypeCode: "NS01", saleName: "乌木黑内饰", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/670688dbd29ded1a8cbc1321.png", saleDesc: "", saleParam: "#424141"),
        SaleModel.init(saleCode: "H01", saleModelType: "WHEEL", saleModelTypeCode: "CL04", saleName: "21寸轮毂(四季胎)枪灰色", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67067e41d29ded1a8cb3ac99.png", saleDesc: "标配倍耐力Scorpion轮胎", saleParam: ""),
        SaleModel.init(saleCode: "H01", saleModelType: "WHEEL", saleModelTypeCode: "CL03", saleName: "21寸轮毂(四季胎)高亮黑", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67067e41d29ded1a8cb3ac99.png", saleDesc: "标配倍耐力Scorpion轮胎", saleParam: ""),
        SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS06", saleName: "冰川白车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67064442d29ded1a8c8801fa.png", saleDesc: "", saleParam: "#e8e8e7"),
        SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS05", saleName: "银河灰车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/6706473ad29ded1a8c8aa3a9.png", saleDesc: "", saleParam: "#868888"),
        SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS04", saleName: "星尘银车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/6706487dd29ded1a8c8bb358.png", saleDesc: "", saleParam: "#cbcbce"),
        SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS03", saleName: "天际蓝车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67064bc8d29ded1a8c8e461b.png", saleDesc: "", saleParam: "#4681ad"),
        SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS02", saleName: "翡翠绿车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png", saleDesc: "", saleParam: "#3a5337"),
        SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS01", saleName: "墨玉黑车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png", saleDesc: "", saleParam: "#0f0e11"),
        SaleModel.init(saleCode: "H01", saleModelType: "SPARE_TIRE", saleModelTypeCode: "X05", saleName: "外挂式全尺寸备胎", salePrice: 6000, saleImage: "https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png", saleDesc: "含备胎车长5295毫米", saleParam: ""),
        SaleModel.init(saleCode: "H01", saleModelType: "SPARE_TIRE", saleModelTypeCode: "X00", saleName: "无备胎", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/670674cfd29ded1a8cac9cb3.png", saleDesc: "车长5050毫米", saleParam: ""),
        SaleModel.init(saleCode: "H01", saleModelType: "MODEL", saleModelTypeCode: "H0106", saleName: "寒01六座版", salePrice: 88888, saleImage: "https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png", saleDesc: "2-2-2六座，双侧零重力航空座椅，行政奢华", saleParam: ""),
        SaleModel.init(saleCode: "H01", saleModelType: "MODEL", saleModelTypeCode: "H0107", saleName: "寒01七座版", salePrice: 88888, saleImage: "https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png", saleDesc: "2-2-3七座，二排超宽通道，二三排可放平", saleParam: "")
    ])
}

/// 订单响应
func mockOrderResponse() -> OrderResponse {
    return OrderResponse.init(
        orderNum: "000000000001"
    )
}

/// 文章
func mockArticle() -> Article {
    return Article.init(
        id: "1",
        title: "旅途的最佳伴侣！",
        content: "趁春节假期，一家四口回了趟四川老家，途经乐山、石棉、泸定、康定、宜宾等地，总行程1954公里。车的表现让我们非常满意，空间大，装载能力强，底盘扎实稳重，时速跑上120公里一点也不飘，特别是翻越折多山时，很多车都挂了防滑链，而我凭着四条AT胎，稳稳的行驶在冰雪路面，满满的安全感。车子的娱乐功能也值得表扬:看电影，听歌曲，唱卡拉OK，让旅途充满了无穷乐趣;增程式可油可电，毫无里程焦虑，说走就走让我觉得当初的选择是非常正确的!在今后的日子里，我们一起继续向山海出发!",
        images: [
            "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
            "https://pic.imgdb.cn/item/65e0201e9f345e8d03620461.png",
            "https://pic.imgdb.cn/item/65df4e159f345e8d0301a944.png",
            "https://pic.imgdb.cn/item/65df55069f345e8d0318a51c.png"
        ],
        ts: 1709218491419,
        username: "hwyz_leo",
        avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663",
        views: 20,
        location: "重庆",
        tags: ["发现家乡的美"],
        comments: [
            ArticleComment.init(id: "1", parentId: "1", comment: "拍的太好了！", ts: 1709261044490, username: "开源汽车爱好者", location: "江苏省"),
            ArticleComment.init(id: "3", parentId: "1", comment: "感谢认可", replyer: "开源汽车爱好者", ts: 1709261044490, username: "hwyz_leo", avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663", location: "上海市"),
            ArticleComment.init(id: "2", parentId: "2", comment: "这景色真美啊", ts: 1709261044490, username: "tina", location: "山东省")
        ],
        likeCount: 12,
        liked: false,
        shareCount: 5
    )
}

/// 爱车首页
func mockVehicleIndex() -> VehicleIndex {
    return VehicleIndex.init(
        vehicle: mockVehicle()
    )
}

/// 车辆
func mockVehicle() -> Vehicle {
    return Vehicle.init(
        vin: "VIN00000000000001",
        bodyImg: "https://pic.imgdb.cn/item/65f1bd8b9f345e8d03cf10cc.png",
        topImg: "https://pic.imgdb.cn/item/65f1bda79f345e8d03cfb31b.png",
        drivingRange: 798,
        electricDrivingRange: 210,
        electricPercentage: 85,
        fuelDrivingRange: 588,
        fuelPercentage: 57,
        interiorTemp: 24,
        flTirePressure: 1.9,
        flTireTemp: 48,
        frTirePressure: 2.0,
        frTireTemp: 49,
        rlTirePressure: 2.0,
        rlTireTemp: 50,
        rrTirePressure: 2.1,
        rrTireTemp: 49,
        lockState: true,
        windowPercentage: 100,
        trunkPercentage: 0
    )
}

/// 商城首页
func mockMallIndex() -> MallIndex {
    return MallIndex.init(
        recommendedProducts: [
            Product.init(id: "1", name: "车载无人机", recommendedCover: "https://pic.imgdb.cn/item/65e9b3879f345e8d036bff96.png"),
            Product.init(id: "2", name: "露营帐篷", recommendedCover: "https://pic.imgdb.cn/item/65e9b3939f345e8d036c2633.png"),
            Product.init(id: "3", name: "车辆模型", recommendedCover: "https://pic.imgdb.cn/item/65e9b39f9f345e8d036c4a0a.png")
        ],
        categories: [
            "品质配件":[
                Product.init(id: "1", name: "车载无人机", cover: "https://pic.imgdb.cn/item/65e9b3879f345e8d036bff96.png", price: 1000),
                Product.init(id: "3", name: "车辆模型", cover: "https://pic.imgdb.cn/item/65e9b39f9f345e8d036c4a0a.png", price: 800)
            ],
            "精致露营":[
                Product.init(id: "2", name: "露营帐篷", cover: "https://pic.imgdb.cn/item/65e9b3939f345e8d036c2633.png", price: 500),
                Product.init(id: "3", name: "车辆模型", cover: "https://pic.imgdb.cn/item/65e9b39f9f345e8d036c4a0a.png", price: 800)
            ]
        ]
    )
}

/// 商品
func mockProduct() -> Product {
    return Product.init(
        id: "1",
        name: "车载无人机",
        cover: "https://pic.imgdb.cn/item/65e9b3879f345e8d036bff96.png",
        images: [
            "https://pic.imgdb.cn/item/65e9b3879f345e8d036bff96.png",
            "https://pic.imgdb.cn/item/65e9b3939f345e8d036c2633.png",
            "https://pic.imgdb.cn/item/65e9b39f9f345e8d036c4a0a.png"
        ],
        price: 1000,
        points: 100000
    )
}

/// 商品订单
func mockProductOrder() -> ProductOrder {
    return ProductOrder.init(
        product: mockProduct(),
        buyCount: 1,
        totalPrice: 1000,
        freight: 5,
        remainingPoints: 230
    )
}
