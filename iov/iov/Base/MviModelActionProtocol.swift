//
//  MviModelActionProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

protocol MviModelActionProtocol: AnyObject {
    /// 显示加载中
    func displayLoading()
    /// 显示错误
    func displayError(text: String)
}
