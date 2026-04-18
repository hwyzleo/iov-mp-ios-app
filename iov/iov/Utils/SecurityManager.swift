//
//  SecurityManager.swift
//  iov
//
//  Created by hwyz_leo on 2024/11/6.
//

import Foundation

class SecurityManager {
    
    /// 生成CSR文件
    func createCsr() -> String {
        return generateRSA2048KeyPair("")
    }
    
    /// 生成公私钥对
    private func generateRSA2048KeyPair(_ key: String) -> String {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false,
                kSecAttrApplicationTag as String: key.data(using: .utf8)!
            ],
            kSecPublicKeyAttrs as String: [
                kSecAttrIsPermanent as String: false,
                kSecAttrApplicationTag as String: key.data(using: .utf8)!
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Private key generation failed: \(error!.takeRetainedValue() as Error)")
            return ""
        }
        
        storePrivateKey(privateKey: privateKey, tag: key)
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Public key extraction failed")
            return ""
        }
        
        // 将公钥转换为数据
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            print("Public key data extraction failed: \(error!.takeRetainedValue() as Error)")
            return ""
        }
        
        return publicKeyData.base64EncodedString()
    }
    
    /// 保存私钥
    private func storePrivateKey(privateKey: SecKey, tag: String) {
        let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, nil) as Data?
        guard let privateKeyData = privateKeyData else {
            print("Failed to get private key data")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecValueData as String: privateKeyData,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnPersistentRef as String: true
        ]
        
        var persistentRef: CFTypeRef?
        let status = SecItemAdd(query as CFDictionary, &persistentRef)
        
        if status == errSecSuccess {
            print("Private key stored successfully")
        } else {
            print("Failed to store private key: \(status)")
        }
    }
    
    /// 签名
    private func signature(plain: String) {
        
    }
    
}
