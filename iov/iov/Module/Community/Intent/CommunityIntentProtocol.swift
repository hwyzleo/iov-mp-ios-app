//
//  CommunityIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/8/31.
//

protocol CommunityIntentProtocol : MviIntentProtocol {
    /// 点击具体内容
    func onTapContent(type: String)
}
