//
//  RealmManager.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import RealmSwift
import KeychainAccess

///Realm存储管理
class RealmManager {
    let configuration: Realm.Configuration
    private var cachedRealm: Realm?
    
    private init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }
    
    var realm: Realm {
        if let cached = cachedRealm {
            cached.refresh()
            return cached
        }
        do {
            let newRealm = try Realm(configuration: configuration)
            cachedRealm = newRealm
            return newRealm
        } catch {
            // 无法完成迁移时按安全策略删除本地库后重建（凭证丢失则要求重新登录）
            if let url = configuration.fileURL {
                try? FileManager.default.removeItem(at: url)
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + ".lock"))
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + ".management"))
            }
            if let recovered = try? Realm(configuration: configuration) {
                cachedRealm = recovered
                return recovered
            }
            fatalError("初始化 Realm 失败 (配置: \(configuration.fileURL?.lastPathComponent ?? "未知")): \(error)")
        }
    }
    
    func invalidateRealm() {
        cachedRealm = nil
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
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("User.realm")
        let encryptionKey = getEncryptionKey(for: "user")
        
        let config = Realm.Configuration(
            fileURL: url,
            encryptionKey: encryptionKey,
            schemaVersion: 3, // 3：新增 userId / sessionId，旧 Token 字段仅供迁移
            migrationBlock: { migration, oldSchemaVersion in
                // 仅新增带默认值的字段，Realm 自动补齐
            },
            deleteRealmIfMigrationNeeded: false,
            objectTypes: [UserManager.self])
        return config
    }()
    public static let user: RealmManager = {
        return RealmManager(configuration: userConfig)
    }()
    
    // MARK: - 车辆
    private static let vehiclesConfig: Realm.Configuration = {
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Vehicles.realm")
        let encryptionKey = getEncryptionKey(for: "vehicles")
        
        let config = Realm.Configuration(
            fileURL: url,
            encryptionKey: encryptionKey,
            schemaVersion: 2, // 提升到 2
            migrationBlock: { migration, oldSchemaVersion in },
            deleteRealmIfMigrationNeeded: true,
            objectTypes: [VehiclePo.self])
        return config
    }()
    public static let vehicle: RealmManager = {
        return RealmManager(configuration: vehiclesConfig)
    }()
    
}
