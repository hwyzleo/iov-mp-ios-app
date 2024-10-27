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

/// 车辆销售订单列表
func mockVehicleSaleOrderList() -> [VehicleSaleOrder] {
    return [
        VehicleSaleOrder.init(orderNum: "ORDERNUM001", orderState: AppGlobalState.shared.mockOrderState.rawValue, displayName: "寒01七座版")
    ]
}

/// 销售车型
func mockSaleModelList() -> [SaleModelConfig] {
    return [
        SaleModelConfig.init(saleCode: "H01", type: "ADAS", typeCode: "X02", typeName: "高阶智驾", typePrice: 3000, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "", typeParam: ""),
        SaleModelConfig.init(saleCode: "H01", type: "ADAS", typeCode: "X00", typeName: "标准智驾", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "", typeParam: ""),
        SaleModelConfig.init(saleCode: "H01", type: "INTERIOR", typeCode: "NS03", typeName: "霜雪白内饰", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"], typeDesc: "", typeParam: "#dcdcd6"),
        SaleModelConfig.init(saleCode: "H01", type: "INTERIOR", typeCode: "NS02", typeName: "珊瑚橙内饰", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670687ecd29ded1a8cbb5280.png"], typeDesc: "", typeParam: "#a35d31"),
        SaleModelConfig.init(saleCode: "H01", type: "INTERIOR", typeCode: "NS01", typeName: "乌木黑内饰", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670688dbd29ded1a8cbc1321.png"], typeDesc: "", typeParam: "#424141"),
        SaleModelConfig.init(saleCode: "H01", type: "WHEEL", typeCode: "CL04", typeName: "21寸轮毂(四季胎)枪灰色", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67067e41d29ded1a8cb3ac99.png"], typeDesc: "标配倍耐力Scorpion轮胎", typeParam: ""),
        SaleModelConfig.init(saleCode: "H01", type: "WHEEL", typeCode: "CL03", typeName: "21寸轮毂(四季胎)高亮黑", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67067e41d29ded1a8cb3ac99.png"], typeDesc: "标配倍耐力Scorpion轮胎", typeParam: ""),
        SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS06", typeName: "冰川白车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67064442d29ded1a8c8801fa.png"], typeDesc: "", typeParam: "#e8e8e7"),
        SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS05", typeName: "银河灰车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/6706473ad29ded1a8c8aa3a9.png"], typeDesc: "", typeParam: "#868888"),
        SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS04", typeName: "星尘银车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/6706487dd29ded1a8c8bb358.png"], typeDesc: "", typeParam: "#cbcbce"),
        SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS03", typeName: "天际蓝车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67064bc8d29ded1a8c8e461b.png"], typeDesc: "", typeParam: "#4681ad"),
        SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS02", typeName: "翡翠绿车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png"], typeDesc: "", typeParam: "#3a5337"),
        SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS01", typeName: "墨玉黑车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "", typeParam: "#0f0e11"),
        SaleModelConfig.init(saleCode: "H01", type: "SPARE_TIRE", typeCode: "X05", typeName: "外挂式全尺寸备胎", typePrice: 6000, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "含备胎车长5295毫米", typeParam: ""),
        SaleModelConfig.init(saleCode: "H01", type: "SPARE_TIRE", typeCode: "X00", typeName: "无备胎", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670674cfd29ded1a8cac9cb3.png"], typeDesc: "车长5050毫米", typeParam: ""),
        SaleModelConfig.init(saleCode: "H01", type: "MODEL", typeCode: "H0106", typeName: "寒01六座版", typePrice: 88888, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "2-2-2六座，双侧零重力航空座椅，行政奢华", typeParam: ""),
        SaleModelConfig.init(saleCode: "H01", type: "MODEL", typeCode: "H0107", typeName: "寒01七座版", typePrice: 88888, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "2-2-3七座，二排超宽通道，二三排可放平", typeParam: "")
    ]
}

/// 心愿单
func mockWishlist() -> Wishlist {
    return Wishlist.init(
        saleCode: "H01",
        orderNum: "ORDERNUM001",
        saleModelConfigType: [
            "ADAS": "X02",
            "WHEEL": "CL03",
            "EXTERIOR": "WS02",
            "INTERIOR": "NS01",
            "MODEL": "H0107",
            "SPARE_TIRE": "X00"
        ],
        saleModelConfigName: [
            "ADAS": "高阶智驾",
            "WHEEL": "21寸轮毂(四季胎)高亮黑",
            "EXTERIOR": "翡翠绿车漆",
            "INTERIOR": "乌木黑内饰",
            "MODEL": "寒01七座版",
            "SPARE_TIRE": "无备胎"
        ],
        saleModelConfigPrice: [
            "ADAS": 10000.00,
            "WHEEL": 0.00,
            "EXTERIOR": 0.00,
            "INTERIOR": 0.00,
            "MODEL": 188888.00,
            "SPARE_TIRE": 0.00
        ],
        saleModelImages: [
            "https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png",
            "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
        ],
        saleModelDesc: "七座 | 有备胎 | 翡翠绿车漆 | 21寸轮毂(四季胎)高亮黑 | 乌木黑内饰 | 高阶智驾",
        totalPrice: 198888.00,
        isValid: true
    )
}

/// 上牌区域
func mockLicenseArea() -> [LicenseArea] {
    return [
        LicenseArea.init(provinceCode: "11", cityCode: nil, displayName: "北京市"),
        LicenseArea.init(provinceCode: "11", cityCode: "1101", displayName: "市辖区"),
        LicenseArea.init(provinceCode: "12", cityCode: nil, displayName: "天津市"),
        LicenseArea.init(provinceCode: "12", cityCode: "1201", displayName: "市辖区"),
        LicenseArea.init(provinceCode: "13", cityCode: nil, displayName: "河北省"),
        LicenseArea.init(provinceCode: "13", cityCode: "1301", displayName: "石家庄市"),
        LicenseArea.init(provinceCode: "14", cityCode: nil, displayName: "山西省"),
        LicenseArea.init(provinceCode: "14", cityCode: "1401", displayName: "太原市"),
        LicenseArea.init(provinceCode: "15", cityCode: nil, displayName: "内蒙古自治区"),
        LicenseArea.init(provinceCode: "15", cityCode: "1501", displayName: "呼和浩特市"),
        LicenseArea.init(provinceCode: "21", cityCode: nil, displayName: "辽宁省"),
        LicenseArea.init(provinceCode: "21", cityCode: "2101", displayName: "沈阳市"),
        LicenseArea.init(provinceCode: "22", cityCode: nil, displayName: "吉林省"),
        LicenseArea.init(provinceCode: "22", cityCode: "2201", displayName: "长春市"),
        LicenseArea.init(provinceCode: "23", cityCode: nil, displayName: "黑龙江省"),
        LicenseArea.init(provinceCode: "23", cityCode: "2301", displayName: "哈尔滨市"),
        LicenseArea.init(provinceCode: "31", cityCode: nil, displayName: "上海市"),
        LicenseArea.init(provinceCode: "31", cityCode: "3101", displayName: "市辖区"),
        LicenseArea.init(provinceCode: "32", cityCode: nil, displayName: "江苏省"),
        LicenseArea.init(provinceCode: "32", cityCode: "3201", displayName: "南京市"),
        LicenseArea.init(provinceCode: "33", cityCode: nil, displayName: "浙江省"),
        LicenseArea.init(provinceCode: "33", cityCode: "3301", displayName: "杭州市"),
        LicenseArea.init(provinceCode: "34", cityCode: nil, displayName: "安徽省"),
        LicenseArea.init(provinceCode: "34", cityCode: "3401", displayName: "合肥市"),
        LicenseArea.init(provinceCode: "35", cityCode: nil, displayName: "福建省"),
        LicenseArea.init(provinceCode: "35", cityCode: "3501", displayName: "福州市"),
        LicenseArea.init(provinceCode: "36", cityCode: nil, displayName: "江西省"),
        LicenseArea.init(provinceCode: "36", cityCode: "3601", displayName: "南昌市"),
        LicenseArea.init(provinceCode: "37", cityCode: nil, displayName: "山东省"),
        LicenseArea.init(provinceCode: "37", cityCode: "3701", displayName: "济南市"),
        LicenseArea.init(provinceCode: "41", cityCode: nil, displayName: "河南省"),
        LicenseArea.init(provinceCode: "41", cityCode: "4101", displayName: "郑州市"),
        LicenseArea.init(provinceCode: "42", cityCode: nil, displayName: "湖北省"),
        LicenseArea.init(provinceCode: "42", cityCode: "4201", displayName: "武汉市"),
        LicenseArea.init(provinceCode: "43", cityCode: nil, displayName: "湖南省"),
        LicenseArea.init(provinceCode: "43", cityCode: "4301", displayName: "长沙市"),
        LicenseArea.init(provinceCode: "44", cityCode: nil, displayName: "广东省"),
        LicenseArea.init(provinceCode: "44", cityCode: "4401", displayName: "广州市"),
        LicenseArea.init(provinceCode: "45", cityCode: nil, displayName: "广西壮族自治区"),
        LicenseArea.init(provinceCode: "45", cityCode: "4501", displayName: "南宁市"),
        LicenseArea.init(provinceCode: "46", cityCode: nil, displayName: "海南省"),
        LicenseArea.init(provinceCode: "46", cityCode: "4601", displayName: "海口市"),
        LicenseArea.init(provinceCode: "50", cityCode: nil, displayName: "重庆市"),
        LicenseArea.init(provinceCode: "50", cityCode: "5001", displayName: "市辖区"),
        LicenseArea.init(provinceCode: "51", cityCode: nil, displayName: "四川省"),
        LicenseArea.init(provinceCode: "51", cityCode: "5101", displayName: "成都市"),
        LicenseArea.init(provinceCode: "52", cityCode: nil, displayName: "贵州省"),
        LicenseArea.init(provinceCode: "52", cityCode: "5201", displayName: "贵阳市"),
        LicenseArea.init(provinceCode: "53", cityCode: nil, displayName: "云南省"),
        LicenseArea.init(provinceCode: "53", cityCode: "5301", displayName: "昆明市"),
        LicenseArea.init(provinceCode: "54", cityCode: nil, displayName: "西藏自治区"),
        LicenseArea.init(provinceCode: "54", cityCode: "5401", displayName: "拉萨市"),
        LicenseArea.init(provinceCode: "61", cityCode: nil, displayName: "陕西省"),
        LicenseArea.init(provinceCode: "61", cityCode: "6101", displayName: "西安市"),
        LicenseArea.init(provinceCode: "62", cityCode: nil, displayName: "甘肃省"),
        LicenseArea.init(provinceCode: "62", cityCode: "6201", displayName: "兰州市"),
        LicenseArea.init(provinceCode: "63", cityCode: nil, displayName: "青海省"),
        LicenseArea.init(provinceCode: "63", cityCode: "6301", displayName: "西宁市"),
        LicenseArea.init(provinceCode: "64", cityCode: nil, displayName: "宁夏回族自治区"),
        LicenseArea.init(provinceCode: "64", cityCode: "6401", displayName: "银川市"),
        LicenseArea.init(provinceCode: "65", cityCode: nil, displayName: "新疆维吾尔自治区"),
        LicenseArea.init(provinceCode: "65", cityCode: "6501", displayName: "乌鲁木齐市"),
        LicenseArea.init(provinceCode: "71", cityCode: nil, displayName: "台湾省"),
        LicenseArea.init(provinceCode: "81", cityCode: nil, displayName: "香港特别行政区"),
        LicenseArea.init(provinceCode: "82", cityCode: nil, displayName: "澳门特别行政区"),
    ]
}

/// 订单
func mockOrder() -> OrderResponse {
    return OrderResponse.init(
        orderNum: "ORDERNUM001",
        orderState: 200,
        saleModelConfigType: [
            "OPTIONAL": "X02",
            "WHEEL": "CL03",
            "EXTERIOR": "WS02",
            "INTERIOR": "NS01",
            "MODEL": "H0107",
            "SPARE_TIRE": "X00"
        ],
        saleModelConfigName: [
            "OPTIONAL": "高阶智驾",
            "WHEEL": "21寸轮毂(四季胎)高亮黑",
            "EXTERIOR": "翡翠绿车漆",
            "INTERIOR": "乌木黑内饰",
            "MODEL": "寒01七座版",
            "SPARE_TIRE": "无备胎"
        ],
        saleModelConfigPrice: [
            "OPTIONAL": 3000.00,
            "WHEEL": 0.00,
            "EXTERIOR": 0.00,
            "INTERIOR": 0.00,
            "MODEL": 8888.00,
            "SPARE_TIRE": 0.00
        ],
        saleModelImages: [
            "https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png",
            "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
        ],
        saleModelDesc: "七座 | 有备胎 | 翡翠绿车漆 | 21寸轮毂(四季胎)高亮黑 | 乌木黑内饰 | 高阶智驾",
        totalPrice: 11888.00,
        orderTime: 1729405288
    )
}

/// 订单支付响应
func mockOrderPaymentResponse() -> OrderPaymentResponse {
    return OrderPaymentResponse.init(
        orderNum: "",
        paymentMerchant: "",
        paymentReference: "",
        paymentAmount: 5000,
        paymentDateType: 1,
        paymentData: ""
    )
}

/// 已选择的销售车型
func mockSelectedSaleModel() -> SelectedSaleModel {
    return SelectedSaleModel.init(
        saleCode: "H01",
        modelName: "寒01六座版",
        earnestMoney: true,
        earnestMoneyPrice: 5000,
        downPayment: true,
        downPaymentPrice: 5000,
        modelConfigCode: "H01060103030102",
        saleModelImages: [
            "https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png",
            "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
        ],
        saleModelDesc: "外挂式全尺寸备胎 | 墨玉黑车漆 | 21寸轮毂(四季胎)高亮黑 | 霜雪白内饰",
        saleModelConfigName: [
            "MODEL": "寒01六座版",
            "SPARE_TIRE": "外挂式全尺寸备胎",
            "EXTERIOR": "墨玉黑车漆",
            "WHEEL": "21寸轮毂(四季胎)高亮黑",
            "INTERIOR": "霜雪白内饰",
            "ADAS": "高价智驾"
        ],
        saleModelConfigPrice: [
            "MODEL": 188888.00,
            "SPARE_TIRE": 6000.00,
            "EXTERIOR": 0.00,
            "WHEEL": 0.00,
            "INTERIOR": 0.00,
            "ADAS": 10000.00
        ],
        totalPrice: 204888.00,
        purchaseBenefitsIntro: "创始权益（价值6000元）\n首年用车服务包（价值999元）\n5000元选配基金（价值5000元）"
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
