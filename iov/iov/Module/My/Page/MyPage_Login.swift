//
//  MyView_LoginContent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyPage {
    struct Login: View {
        var user: UserManager
        var tapMessageAction: (() -> Void)?
        var tapSettingAction: (() -> Void)?
        var tapUserAction: (() -> Void)?
        var tapOrderAction: (() -> Void)?
        var tapChargingPileAction: (() -> Void)?
        
        private let gridItems = [
            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
        ]
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                MyPage.TopBar(
                    tapMessageAction: { tapMessageAction?() },
                    tapSettingAction: { tapSettingAction?() }
                )
                .padding(.horizontal, AppTheme.layout.margin)
                
                ScrollView {
                    VStack(spacing: AppTheme.layout.spacing) {
                        
                        // 第2块：用户信息与社交统计
                        VStack(spacing: 24) {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(user.nickname)
                                        .font(AppTheme.fonts.bigTitle)
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                    Text("编辑个人资料 >")
                                        .font(AppTheme.fonts.subtext)
                                        .foregroundColor(AppTheme.colors.fontSecondary)
                                }
                                Spacer()
                                Button(action: { tapUserAction?() }) {
                                    AvatarImage(avatar: user.avatar, width: 70)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            HStack(spacing: 0) {
                                StatItem(count: user.followingCount, label: "关注")
                                StatItem(count: user.followerCount, label: "粉丝")
                                StatItem(count: user.postCount, label: "发布")
                                StatItem(count: user.collectionCount, label: "收藏")
                            }
                        }
                        .appCardStyle()
                        
                        // 第3块：消息提醒
                        Button(action: { tapMessageAction?() }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Image("icon_bell")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(AppTheme.colors.brandMain)
                                        .frame(width: 24, height: 24)
                                    
                                    if user.unreadMsgCount > 0 {
                                        Text("\(user.unreadMsgCount)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.black)
                                            .frame(width: 16, height: 16)
                                            .background(AppTheme.colors.brandMain)
                                            .clipShape(Circle())
                                            .offset(x: 10, y: -10)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("消息中心")
                                        .font(AppTheme.fonts.body)
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                    Text(user.latestMsgTitle.isEmpty ? "暂无新消息" : user.latestMsgTitle)
                                        .font(AppTheme.fonts.subtext)
                                        .foregroundColor(AppTheme.colors.fontSecondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.colors.fontTertiary)
                            }
                        }
                        .buttonStyle(.plain)
                        .appCardStyle()
                        
                        // 第4块：功能宫格
                        VStack(alignment: .leading, spacing: 16) {
                            Text("常用功能")
                                .font(AppTheme.fonts.title1)
                                .foregroundColor(AppTheme.colors.fontPrimary)
                            
                            LazyVGrid(columns: gridItems, spacing: 24) {
                                FeatureItem(icon: "diamond", label: "我的积分")
                                FeatureItem(icon: "medal", label: "我的权益")
                                FeatureItem(icon: "file", label: "我的卡包")
                                FeatureItem(icon: "order", label: "我的订单")
                                FeatureItem(icon: "icon_lock", label: "我的金融")
                                FeatureItem(icon: "invite", label: "我的卡券")
                                FeatureItem(icon: "icon_vehicle", label: "我的预约")
                                FeatureItem(icon: "testDriveReport", label: "我的试驾")
                                FeatureItem(icon: "icon_circle_check", label: "我的保单")
                                FeatureItem(icon: "article", label: "我的活动")
                                FeatureItem(icon: "chargingPile", label: "我的家充桩")
                                Spacer()
                            }
                        }
                        .appCardStyle()
                        
                        // 第5块：服务支持
                        VStack(spacing: 0) {
                            ListRowItem(icon: "icon_modify", label: "意见反馈")
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 50)
                            ListRowItem(icon: "phone", label: "联系客服")
                        }
                        .appCardStyle()
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.top, 20)
                }
                .scrollIndicators(.hidden)
            }
            .appBackground()
        }
    }
}

// MARK: - 辅助组件

private struct StatItem: View {
    let count: Int
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.colors.fontPrimary)
            Text(label)
                .font(AppTheme.fonts.subtext)
                .foregroundColor(AppTheme.colors.fontSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FeatureItem: View {
    let icon: String
    let label: String
    var body: some View {
        VStack(spacing: 12) {
            Image(icon)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppTheme.colors.brandMain)
                .frame(width: 26, height: 26)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.colors.fontPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ListRowItem: View {
    let icon: String
    let label: String
    var body: some View {
        HStack(spacing: 16) {
            Image(icon)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppTheme.colors.fontSecondary)
                .frame(width: 20, height: 20)
            Text(label)
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.colors.fontTertiary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 4)
    }
}

struct MyView_Login_Previews: PreviewProvider {
    static var previews: some View {
        // 由于 UserManager 需要 Realm 环境，这里可以使用普通对象包装一下，
        // 或者简单地传一个 mock 对象
        let user = UserManager()
        let mock = mockLoginResponse()
        user.nickname = mock.nickname
        user.avatar = mock.avatar
        user.followingCount = mock.followingCount ?? 0
        user.followerCount = mock.followerCount ?? 0
        user.postCount = mock.postCount ?? 0
        user.collectionCount = mock.collectionCount ?? 0
        user.unreadMsgCount = mock.unreadMsgCount ?? 0
        user.latestMsgTitle = mock.latestMsgTitle ?? ""
        
        return MyPage.Login(user: user)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
