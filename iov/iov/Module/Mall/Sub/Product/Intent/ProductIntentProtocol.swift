//
//  ProductIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

protocol ProductIntentProtocol : MviIntentProtocol {
    /// 页面出现
    func viewOnAppear(id: String)
    /// 点击购买按钮
    func onTapBuyButton()
}
