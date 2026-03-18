//
//  UserManager.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftyJSON
import RealmSwift
import RxSwift

@objcMembers
class UserManager: Object {
    
    /// 用户令牌
    dynamic var token: String = ""
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
        self.nickname = response.nickname
        self.avatar = response.avatar
        self.token = response.token
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
    
    /// 修改昵称
    class func modifyNickname(nickname: String) -> Observable<UserManager> {
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
                    // 如果已存在对象，则更新其属性，保持引用有效
                    user.token = response.token
                    user.nickname = response.nickname
                    user.avatar = response.avatar
                    user.followingCount = response.followingCount ?? 0
                    user.followerCount = response.followerCount ?? 0
                    user.postCount = response.postCount ?? 0
                    user.collectionCount = response.collectionCount ?? 0
                    user.unreadMsgCount = response.unreadMsgCount ?? 0
                    user.latestMsgTitle = response.latestMsgTitle ?? ""
                    userResult = user
                } else {
                    // 如果不存在，则创建新对象
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
