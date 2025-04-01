//
//  RealmManager.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import RealmSwift
import KeychainAccess

///Realm存储管理
struct RealmManager {
    let configuration: Realm.Configuration
    
    private init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }
    
    var realm: Realm {
        do {
            return try Realm(configuration: configuration)
        } catch {
            print("使用自定义配置初始化 Realm 失败: \(error)")
            do {
                return try Realm()
            } catch {
                fatalError("初始化 Realm 失败: \(error)")
            }
        }
    }
    
    // 获取或创建加密密钥
    private static func getEncryptionKey(for identifier: String) -> Data {
        let keychain = KeychainAccess.Keychain(service: "net.hwyz.iov.mp.app")
        let keyIdentifier = "realm_encryption_key_\(identifier)"
        
        if let existingKey = try? keychain.getData(keyIdentifier) {
            return existingKey
        } else {
            var encryptionKey = Data(count: 64)
            _ = encryptionKey.withUnsafeMutableBytes { bytes in
                SecRandomCopyBytes(kSecRandomDefault, 64, bytes.baseAddress!)
            }
            try? keychain.set(encryptionKey, key: keyIdentifier)
            return encryptionKey
        }
    }
    
    // MARK: - 用户
    private static let userConfig: Realm.Configuration = {
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("User")
        let encryptionKey = getEncryptionKey(for: "user")
        
        let config = Realm.Configuration(
            fileURL: url,
            encryptionKey: encryptionKey,
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // 处理数据迁移
                }
            },
            objectTypes: [UserManager.self])
        return config
    }()
    public static let user: RealmManager = {
        return RealmManager(configuration: userConfig)
    }()
    
    // MARK: - 车辆
    private static let vehiclesConfig: Realm.Configuration = {
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Vehicles")
        let encryptionKey = getEncryptionKey(for: "vehicles")
        
        let config = Realm.Configuration(
            fileURL: url,
            encryptionKey: encryptionKey,
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // 处理数据迁移
                }
            },
            objectTypes: [VehiclePo.self])
        return config
    }()
    public static let vehicle: RealmManager = {
        return RealmManager(configuration: vehiclesConfig)
    }()
    
}
