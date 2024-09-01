//
//  CommunityIntentProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/8/31.
//

protocol CommunityIntentProtocol : MviIntentProtocol {
    /// 点击具体内容
    func onTapContent(type: String)
}
