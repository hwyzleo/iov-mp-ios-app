//
//  OrderIntentProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

protocol OrderIntentProtocol : MviIntentProtocol {
    /// 页面出现
    func viewOnAppear(id: String, buyCount: Int)
    /// 点击收货地址
    func onTapAddress()
}
