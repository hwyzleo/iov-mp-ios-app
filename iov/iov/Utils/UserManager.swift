//
//  UserManager.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftyJSON
import RealmSwift
import RxSwift

@objcMembers
class UserManager: Object {
    
    /// 用户标识（与认证会话关联，资料用途）
    dynamic var userId: String = ""
    /// 会话标识（与认证会话关联，资料用途）
    dynamic var sessionId: String = ""
    /// 旧版本用户令牌（仅用于一次性迁移读取，不再作为 Token 事实存储）
    dynamic var token: String = ""
    /// 旧版本刷新令牌（仅用于一次性迁移读取，不再作为 Token 事实存储）
    dynamic var refreshToken: String = ""
    /// 旧版本令牌过期时间（仅用于一次性迁移读取）
    dynamic var tokenExpiresAt: Date?
    /// 用户昵称
    dynamic var nickname: String = ""
    /// 用户头像
    dynamic var avatar: String = ""
    /// 社交统计
    dynamic var followingCount: Int = 0
    dynamic var followerCount: Int = 0
    dynamic var postCount: Int = 0
    dynamic var collectionCount: Int = 0
    /// 消息提醒
    dynamic var unreadMsgCount: Int = 0
    dynamic var latestMsgTitle: String = ""
    
    private convenience init(response: LoginResponse) {
        self.init()
        self.nickname = response.nickname ?? ""
        self.avatar = response.avatar ?? ""
        self.userId = response.userId
        self.sessionId = response.sessionId ?? ""
        self.followingCount = response.followingCount ?? 0
        self.followerCount = response.followerCount ?? 0
        self.postCount = response.postCount ?? 0
        self.collectionCount = response.collectionCount ?? 0
        self.unreadMsgCount = response.unreadMsgCount ?? 0
        self.latestMsgTitle = response.latestMsgTitle ?? ""
    }
    
    /// 获取用户信息
    class func getUser() -> UserManager? {
        let realm = RealmManager.user.realm
        realm.refresh()
        guard let user = realm.objects(UserManager.self).first,
              !user.isInvalidated else {
            return nil
        }
        return user
    }
    
    /// 是否有头像
    class func hasAvatar() -> Bool {
        return (getUser()?.avatar ?? "").isEmpty ? false : true
    }

    /// 修改昵称（内部方法）
    private class func updateNickname(nickname: String) -> Observable<UserManager> {
        let realm = RealmManager.user.realm
        do {
            var userResult: UserManager?
            try realm.write {
                if let user = realm.objects(UserManager.self).first, !user.isInvalidated {
                    user.nickname = nickname
                    userResult = user
                }
            }
            if let result = userResult {
                return Observable.just(result)
            }
            return .error(IovError(message: "用户不存在"))
        } catch {
            return .error(error)
        }
    }
    
    /// 更新登录用户资料（仅资料，不含凭证；凭证由 AuthSessionRepository 存入 Keychain）
    @discardableResult
    class func updateProfile(response: LoginResponse) -> Observable<UserManager> {
        let realm = RealmManager.user.realm
        do {
            var userResult: UserManager?
            try realm.write {
                if let user = realm.objects(UserManager.self).first, !user.isInvalidated {
                    // 旧版本 Realm 中的凭证字段在迁移后必须保持为空，不做双写
                    user.token = ""
                    user.refreshToken = ""
                    user.tokenExpiresAt = nil
                    user.userId = response.userId
                    user.sessionId = response.sessionId ?? ""
                    user.nickname = response.nickname ?? ""
                    user.avatar = response.avatar ?? ""
                    user.followingCount = response.followingCount ?? 0
                    user.followerCount = response.followerCount ?? 0
                    user.postCount = response.postCount ?? 0
                    user.collectionCount = response.collectionCount ?? 0
                    user.unreadMsgCount = response.unreadMsgCount ?? 0
                    user.latestMsgTitle = response.latestMsgTitle ?? ""
                    userResult = user
                } else {
                    let user = UserManager(response: response)
                    realm.add(user)
                    userResult = user
                }
            }
            if let result = userResult {
                return Observable.just(result)
            }
        } catch {
            return Observable.error(error)
        }
        return Observable.error(IovError(message: "登录失败"))
    }

    /// 修改昵称
    class func modifyNickname(nickname: String) -> Observable<UserManager> {
        return updateNickname(nickname: nickname)
    }

    /// 更新昵称和头像（登录后获取用户信息）
    class func updateNicknameAndAvatar(nickname: String, avatar: String) {
        let realm = RealmManager.user.realm
        do {
            try realm.write {
                if let user = realm.objects(UserManager.self).first, !user.isInvalidated {
                    user.nickname = nickname
                    user.avatar = avatar
                }
            }
        } catch {
            print("更新昵称头像失败: \(error)")
        }
    }

    /// 退出登录
    @discardableResult
    class func logout() -> Observable<Void> {
        return clear()
    }
    
    /// 清除用户信息
    @discardableResult
    private class func clear() -> Observable<Void> {
        let realm = RealmManager.user.realm
        do {
            try realm.write {
                realm.delete(realm.objects(UserManager.self))
                realm.refresh()
            }
            VehicleManager.shared.clear()
            return Observable.just(())
        } catch {
            return Observable.error(error)
        }
    }
    
}
