//
//  EarnestMoneyPayPage.swift
//  iov
//
//  Created on 2026/5/13.
//

import SwiftUI

struct EarnestMoneyPayPage: View {
    @StateObject var container: MviContainer<EarnestMoneyPayIntentProtocol, any EarnestMoneyPayModelStateProtocol>
    private var intent: EarnestMoneyPayIntentProtocol { container.intent }
    private var state: any EarnestMoneyPayModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            AppTheme.colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopBackTitleBar(titleLocal: "意向金支付")
                    .frame(height: 54)
                
                ScrollView {
                    VStack(spacing: AppTheme.layout.spacing) {
                        contentView
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                }
                
                bottomButton
            }
        }
        .modifier(MarketingRouter(subjects: state.routerSubject))
        .onAppear {
            intent.viewOnAppear()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch state.contentState {
        case .loading:
            LoadingTip()
        case .ready:
            readyView
        case .paying:
            payingView
        case .success:
            successView
        case .failed(let text):
            ErrorTip(text: text)
        case .expired:
            expiredView
        }
    }
    
    private var readyView: some View {
        VStack(spacing: 24) {
            amountSection
            countdownSection
            channelSection
            instructionSection
        }
    }
    
    private var amountSection: some View {
        VStack(spacing: 8) {
            Text("支付金额")
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontSecondary)
            
            if let amount = state.payInfo?.earnestMoneyAmount {
                Text("¥\(amount.formatted())")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(AppTheme.colors.brandMain)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var countdownSection: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(AppTheme.colors.fontSecondary)
            Text("剩余时间")
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontSecondary)
            
            Spacer()
            
            Text(formatCountdown(state.remainingSeconds))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(state.remainingSeconds < 60 ? .red : AppTheme.colors.fontPrimary)
        }
        .padding()
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(12)
    }
    
    private func formatCountdown(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
    
    private var channelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择支付方式")
                .font(AppTheme.fonts.title1)
                .foregroundColor(AppTheme.colors.fontPrimary)
            
            if let channels = state.payInfo?.paymentChannels {
                ForEach(channels) { channel in
                    ChannelItem(
                        channel: channel,
                        isSelected: state.selectedChannel?.channelCode == channel.channelCode
                    ) {
                        intent.onTapChannel(channel: channel)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(12)
    }
    
    private var instructionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("付款说明")
                .font(AppTheme.fonts.title1)
                .foregroundColor(AppTheme.colors.fontPrimary)
            
            Text("1. 意向金可随时退还，支付后不影响最终购车决策；\n2. 支付成功后，订单状态将自动更新；\n3. 如遇支付问题，请联系客服处理。")
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontSecondary)
                .lineSpacing(5)
        }
        .padding()
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(12)
    }
    
    private var payingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.colors.brandMain))
                .scaleEffect(1.5)
            
            Text("正在支付...")
                .font(AppTheme.fonts.title1)
                .foregroundColor(AppTheme.colors.fontPrimary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var successView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("支付成功")
                .font(AppTheme.fonts.bigTitle)
                .foregroundColor(AppTheme.colors.fontPrimary)
            
            Text("正在返回订单详情...")
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontSecondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var expiredView: some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("支付已超时")
                .font(AppTheme.fonts.bigTitle)
                .foregroundColor(AppTheme.colors.fontPrimary)
            
            Text("订单已过期，请重新下单")
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontSecondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var bottomButton: some View {
        VStack(spacing: 0) {
            let isDisabled = state.contentState != .ready
            
            RoundedCornerButton(
                nameLocal: "立即支付",
                color: isDisabled ? AppTheme.colors.fontTertiary : .black,
                bgColor: isDisabled ? AppTheme.colors.cardBackground : AppTheme.colors.brandMain
            ) {
                if !isDisabled {
                    intent.onTapPay()
                }
            }
            .disabled(isDisabled)
            .padding(.horizontal, AppTheme.layout.margin)
            .padding(.top, 20)
            .padding(.bottom, 34)
        }
        .background(AppTheme.colors.cardBackground.shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5))
        .ignoresSafeArea()
    }
}

private struct ChannelItem: View {
    let channel: PaymentChannelInfo
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                channelIcon
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(channel.channelName)
                        .font(AppTheme.fonts.body)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    
                    if channel.isDefault {
                        Text("推荐")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.colors.brandMain)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? AppTheme.colors.brandMain : AppTheme.colors.fontTertiary)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
    
    private var channelIcon: some View {
        Image(systemName: iconForChannel(channel.channelCode))
            .font(.system(size: 24))
            .foregroundColor(iconColorForChannel(channel.channelCode))
            .frame(width: 40)
    }
    
    private func iconForChannel(_ code: String) -> String {
        switch code {
        case "WECHAT": return "message.fill"
        case "ALIPAY": return "wallet.fill"
        case "UNION_PAY": return "creditcard.fill"
        default: return "creditcard"
        }
    }
    
    private func iconColorForChannel(_ code: String) -> Color {
        switch code {
        case "WECHAT": return .green
        case "ALIPAY": return .blue
        case "UNION_PAY": return .red
        default: return AppTheme.colors.fontSecondary
        }
    }
}