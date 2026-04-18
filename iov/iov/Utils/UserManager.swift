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
    
    /// 用户令牌
    dynamic var token: String = ""
    /// 刷新令牌
    dynamic var refreshToken: String = ""
    /// 令牌过期时间
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
        self.token = response.token ?? ""
        self.refreshToken = response.refreshToken ?? ""
        self.tokenExpiresAt = response.tokenExpires.map { Date(timeIntervalSince1970: Double($0) / 1000.0) }
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
        return realm.objects(UserManager.self).first
    }
    
    /// 是否登录
    class func isLogin() -> Bool {
        return getToken().isEmpty ? false : true
    }
    
    /// 是否有头像
    class func hasAvatar() -> Bool {
        return (getUser()?.avatar ?? "").isEmpty ? false : true
    }
    
    /// 获取令牌
    class func getToken() -> String {
        return getUser()?.token ?? ""
    }
    
    /// 获取刷新令牌
    class func getRefreshToken() -> String {
        return getUser()?.refreshToken ?? ""
    }
    
    /// 检查 token 是否有效
    class func isTokenValid() -> Bool {
        guard let expiresAt = getUser()?.tokenExpiresAt else {
            return false
        }
        return expiresAt.timeIntervalSinceNow > 0
    }
    
    /// 检查 token 是否即将过期（剩余时间小于指定秒数）
    class func isTokenExpiringSoon(threshold: TimeInterval = 300) -> Bool {
        guard let expiresAt = getUser()?.tokenExpiresAt else {
            return true
        }
        return expiresAt.timeIntervalSinceNow <= threshold
    }
    
    /// 更新令牌
    class func updateTokens(token: String, refreshToken: String, expiresAt: Date) {
        let realm = RealmManager.user.realm
        do {
            try realm.write {
                if let user = realm.objects(UserManager.self).first {
                    user.token = token
                    user.refreshToken = refreshToken
                    user.tokenExpiresAt = expiresAt
                }
            }
        } catch {
            print("更新令牌失败：\(error)")
        }
    }

    /// 修改昵称（内部方法）
    private class func updateNickname(nickname: String) -> Observable<UserManager> {
        do {
            if let user = getUser() {
                let realm = RealmManager.user.realm
                try realm.write {
                    user.nickname = nickname
                }
                return .just(user)
            }
            return .error(IovError(message: "用户不存在"))
        } catch {
            return .error(error)
        }
    }
    
    /// 登录
    @discardableResult
    class func login(response: LoginResponse) -> Observable<UserManager> {
        let realm = RealmManager.user.realm
        do {
            var userResult: UserManager?
            try realm.write {
                if let user = realm.objects(UserManager.self).first {
                    user.token = response.token ?? ""
                    user.refreshToken = response.refreshToken ?? ""
                    user.tokenExpiresAt = response.tokenExpires.map { Date(timeIntervalSince1970: Double($0) / 1000.0) }
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
                if let user = realm.objects(UserManager.self).first {
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
            return Observable.just(())
        } catch {
            return Observable.error(error)
        }
    }
    
}
