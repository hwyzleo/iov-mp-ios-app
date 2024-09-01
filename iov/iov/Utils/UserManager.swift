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
class User: Object {
    
    /// 用户令牌
    dynamic var token: String = ""
    /// 用户昵称
    dynamic var nickname: String = ""
    /// 用户头像
    dynamic var avatar: String = ""
    
    convenience init(json: JSON) {
        self.init()
        self.nickname = json["nickname"].stringValue
        self.avatar = json["avatar"].stringValue
    }
    
    convenience init(response: LoginResponse) {
        self.init()
        self.nickname = response.nickname
        self.avatar = response.avatar
        self.token = response.token
    }
    
    /// 获取用户信息
    class func getUser() -> User? {
        return RealmManager.user.realm.objects(User.self).first
    }
    
    /// 获取测试用户信息
    class func getMockUser() -> User {
        let user = User()
        user.nickname = "hwyz_leo"
        return user
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
    class func modifyNickname(nickname: String) -> Observable<User> {
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
    
    /// 创建用户信息
    @discardableResult
    class func create(user: User) -> Observable<User> {
        clear()
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
    
    /// 清除用户信息
    @discardableResult
    class func clear() -> Observable<Void> {
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
