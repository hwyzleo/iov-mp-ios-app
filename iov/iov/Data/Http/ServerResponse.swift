//
//  ServerResponse.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

/*
 * 通用列表数据实体
 */
struct DataList<Model: Codable>: Codable {
    let total: Int
    var records: [Model]
    let page: Int
    let pageSize: Int
}
