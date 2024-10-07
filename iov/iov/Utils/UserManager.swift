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
    
    private convenience init(response: LoginResponse) {
        self.init()
        self.nickname = response.nickname
        self.avatar = response.avatar
        self.token = response.token
    }
    
    /// 获取用户信息
    class func getUser() -> UserManager? {
        return RealmManager.user.realm.objects(UserManager.self).first
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
        clear()
        let user = UserManager(response: response)
        let realm = RealmManager.user.realm
        do {
            try realm.write {
                realm.add(user)
            }
            return .just(user)
        } catch {
            return .error(error)
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
                realm.deleteAll()
                realm.refresh()
            }
            return .just(())
        } catch {
            return .error(error)
        }
    }
    
}
