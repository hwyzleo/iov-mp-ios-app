//
//  RealmManager.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import RealmSwift

///Realm存储管理
struct RealmManager {
    let configuration: Realm.Configuration
    
    private init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }
    
    var realm: Realm {
        return try! Realm(configuration: configuration)
    }
    
    // MARK: - 用户
    private static let userConfig: Realm.Configuration = {
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("User")
        let config = Realm.Configuration(
            fileURL: url,
            schemaVersion: 1,
            migrationBlock: nil,
            objectTypes: [User.self])
        return config
    }()
    public static let user: RealmManager = {
        return RealmManager(configuration: userConfig)
    }()
    
}
