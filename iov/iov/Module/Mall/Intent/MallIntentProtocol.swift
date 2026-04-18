//
//  MallIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

protocol MallIntentProtocol : MviIntentProtocol {
    /// 点击产品
    func onTapProduct(id: String)
}
