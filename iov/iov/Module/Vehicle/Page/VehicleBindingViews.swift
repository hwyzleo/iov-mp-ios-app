//
//  VehicleBindingViews.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-010 on 2026/11/21.
//

import SwiftUI
import AVFoundation
import Kingfisher

// MARK: - 扫码入口（相机权限 + 扫码）

/// 绑车扫码页。
///
/// 设计依据：IOS-APP-DSN-CR-010 D-010-3。
/// - 相机权限被拒绝时解释原因并引导系统设置，允许返回；
/// - 扫码结果只用于“待确认车辆信息”，不代表绑定成功。
struct VehicleBindingScanView: View {
    var onResult: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    var body: some View {
        ZStack {
            switch authStatus {
            case .authorized:
                CustomScannerView(backAction: { dismiss() }) { code in
                    // 先关闭相机页，再提交扫码结果，避免弹层与全屏页相互抢展示
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onResult(code)
                    }
                }
                .ignoresSafeArea()
            case .notDetermined:
                AppTheme.colors.background.ignoresSafeArea()
                ProgressView().tint(AppTheme.colors.brandMain)
            default:
                permissionDenied
            }
        }
        .onAppear(perform: refreshPermission)
    }

    private var permissionDenied: some View {
        ZStack {
            AppTheme.colors.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.colors.fontSecondary)
                Text("vehicle_binding_camera_denied")
                    .font(AppTheme.fonts.body)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("vehicle_binding_open_settings")
                        .font(AppTheme.fonts.title1)
                        .foregroundColor(AppTheme.colors.brandMain)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(AppTheme.colors.cardBackground)
                        .clipShape(Capsule())
                }
                Button {
                    dismiss()
                } label: {
                    Text("vehicle_binding_back")
                        .font(AppTheme.fonts.subtext)
                        .foregroundColor(AppTheme.colors.fontSecondary)
                }
            }
        }
    }

    private func refreshPermission() {
        authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        guard authStatus == .notDetermined else { return }
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                authStatus = granted ? .authorized : .denied
            }
        }
    }
}

// MARK: - 绑定状态条

struct VehicleBindingStatusBanner: View {
    let displayState: VehiclePageDisplayState
    let maskedVin: String?
    let onRetry: () -> Void

    var body: some View {
        switch displayState {
        case .loading:
            banner(icon: "arrow.triangle.2.circlepath") {
                HStack(spacing: 10) {
                    ProgressView().tint(AppTheme.colors.brandMain)
                    Text("vehicle_binding_status_loading")
                        .font(AppTheme.fonts.subtext)
                        .foregroundColor(AppTheme.colors.fontSecondary)
                    Spacer()
                }
            }
        case .unknown:
            banner(icon: "questionmark.circle") {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("vehicle_binding_status_unknown")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        Text("vehicle_binding_status_unknown_hint")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.colors.fontTertiary)
                    }
                    Spacer()
                    Button(action: onRetry) {
                        Text("vehicle_binding_retry")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.brandMain)
                    }
                }
            }
        case .bound, .boundLoginPending:
            banner(icon: "checkmark.shield") {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("vehicle_binding_bound")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        if let maskedVin {
                            Text(maskedVin)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(AppTheme.colors.fontTertiary)
                        }
                        Spacer()
                    }
                    // 当前无车机登录状态查询接口：只给操作指引，不声称已登录/一定待完成
                    Text(displayState == .boundLoginPending
                         ? "vehicle_binding_login_guidance"
                         : "vehicle_binding_login_state_unavailable")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.colors.fontSecondary)
                }
            }
        case .unbound:
            EmptyView()
        }
    }

    private func banner<Content: View>(icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.colors.brandMain)
                .padding(.top, 2)
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(AppTheme.layout.radiusSmall)
    }
}

// MARK: - 未绑定卡片

/// 当前账号明确未绑定时展示；只在关系权威明确返回“未绑定”后可达。
struct VehicleUnboundCard: View {
    let vehicle: Vehicle?
    let displayName: String?
    let maskedVin: String?
    let onScan: () -> Void
    let onHowToBind: () -> Void
    let onOrderDetail: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if let bodyImg = vehicle?.bodyImg, let url = URL(string: bodyImg) {
                KFImage(url)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            } else {
                RoundedRectangle(cornerRadius: AppTheme.layout.radiusSmall)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "car.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.colors.fontTertiary)
                    )
            }

            VStack(spacing: 6) {
                Text("vehicle_binding_delivered")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.colors.brandMain)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.colors.brandMain.opacity(0.12))
                    .clipShape(Capsule())
                if let displayName, !displayName.isEmpty {
                    Text(displayName)
                        .font(AppTheme.fonts.title1)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                }
                if let maskedVin {
                    Text(maskedVin)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(AppTheme.colors.fontSecondary)
                }
            }

            VStack(spacing: 8) {
                Text("vehicle_binding_unbound_title")
                    .font(AppTheme.fonts.title1)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                Text("vehicle_binding_unbound_desc")
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onScan) {
                HStack(spacing: 8) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("vehicle_binding_scan")
                }
                .font(AppTheme.fonts.title1)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.colors.brandMain)
                .clipShape(Capsule())
            }

            HStack(spacing: 20) {
                Button(action: onHowToBind) {
                    Text("vehicle_binding_how_to")
                        .font(AppTheme.fonts.subtext)
                        .foregroundColor(AppTheme.colors.brandMain)
                }
                Button(action: onOrderDetail) {
                    Text("vehicle_binding_order_detail")
                        .font(AppTheme.fonts.subtext)
                        .foregroundColor(AppTheme.colors.fontSecondary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(AppTheme.layout.radiusLarge)
    }
}

// MARK: - 如何绑定

struct VehicleHowToBindSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("vehicle_binding_how_to")
                    .font(AppTheme.fonts.title1)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(AppTheme.colors.fontSecondary)
                }
            }
            Text("vehicle_binding_how_to_content")
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(24)
        .background(AppTheme.colors.background.ignoresSafeArea())
        .presentationDetents([.medium])
    }
}

// MARK: - 确认绑定弹层

struct VehicleBindingConfirmSheet: View {
    let session: VehicleBindingSession
    let operationState: VehicleBindingOperationState
    let lastFailure: VehicleBindingFailure?
    let pollingExhausted: Bool
    let onConfirm: () -> Void
    let onRefresh: () -> Void
    let onCancel: () -> Void
    let onRescan: () -> Void

    /// 本地状态机判定（仅 SCANNED + 未本地过期可提交）
    private var blockReason: VehicleBindingSessionBlockReason? {
        session.blockReason(now: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("vehicle_binding_confirm_title")
                    .font(AppTheme.fonts.title1)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundColor(AppTheme.colors.fontSecondary)
                }
                .disabled(operationState.isSubmitting)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("vehicle_binding_confirm_vin")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.colors.fontTertiary)
                Text(VehicleVinMask.mask(session.vin) ?? "****")
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundColor(AppTheme.colors.fontPrimary)
                if let state = session.state {
                    Text(stateText(state))
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.colors.fontSecondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.colors.cardBackground)
            .cornerRadius(AppTheme.layout.radiusSmall)

            statusSection

            Spacer()
        }
        .padding(24)
        .background(AppTheme.colors.background.ignoresSafeArea())
        .presentationDetents([.medium])
        .interactiveDismissDisabled(operationState.isSubmitting)
    }

    @ViewBuilder
    private var statusSection: some View {
        // D-011-2 §4.2：非 canConfirm 时不渲染「确认绑定」，改为对应提示 + 「重新扫码」
        if let blockReason, !operationState.isSubmitting {
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedStringKey(blockReason.localizationKey))
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if case .bound = blockReason {
                    actionButton(title: "vehicle_binding_done", action: onCancel)
                } else {
                    actionButton(title: "vehicle_binding_rescan", action: onRescan)
                    Button(action: onCancel) {
                        Text("vehicle_binding_cancel")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        } else {
            operationSection
        }
    }

    @ViewBuilder
    private var operationSection: some View {
        switch operationState {
        case .idle:
            actionButton(title: "vehicle_binding_confirm_action", action: onConfirm)
            Button(action: onCancel) {
                Text("vehicle_binding_cancel")
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontTertiary)
                    .frame(maxWidth: .infinity)
            }
        case .submitting:
            HStack(spacing: 10) {
                ProgressView().tint(AppTheme.colors.brandMain)
                Text("vehicle_binding_submitting")
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontSecondary)
            }
        case .resultUnknown:
            VStack(alignment: .leading, spacing: 10) {
                Text("vehicle_binding_result_unknown")
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                if let lastFailure {
                    Text(LocalizedStringKey(lastFailure.localizationKey))
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.colors.fontTertiary)
                }
                if pollingExhausted {
                    // 达到退避上限：保持结果未知并保留手动刷新，不谎报成功/失败
                    Text("vehicle_binding_polling_exhausted")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.colors.fontTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                actionButton(title: "vehicle_binding_refresh_result", action: onRefresh)
            }
        case .succeeded:
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.colors.brandMain)
                    Text("vehicle_binding_bound")
                        .font(AppTheme.fonts.title1)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                }
                Text("vehicle_binding_login_guidance")
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontSecondary)
                actionButton(title: "vehicle_binding_done", action: onCancel)
            }
        case .failed(let failure):
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedStringKey(failure.localizationKey))
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                actionButton(title: "vehicle_binding_rescan", action: onRescan)
            }
        }
    }

    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(LocalizedStringKey(title))
                .font(AppTheme.fonts.title1)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.colors.brandMain)
                .clipShape(Capsule())
        }
    }

    private func stateText(_ state: ActivationSessionState) -> String {
        switch state {
        case .issued: return NSLocalizedString("vehicle_binding_session_issued", comment: "")
        case .scanned: return NSLocalizedString("vehicle_binding_session_scanned", comment: "")
        case .bound: return NSLocalizedString("vehicle_binding_session_bound", comment: "")
        case .cancelled: return NSLocalizedString("vehicle_binding_session_cancelled", comment: "")
        case .expired: return NSLocalizedString("vehicle_binding_session_expired", comment: "")
        case .skipped: return NSLocalizedString("vehicle_binding_session_skipped", comment: "")
        case .unknown: return NSLocalizedString("vehicle_binding_session_unknown_hint", comment: "")
        }
    }
}

// MARK: - 扫码失败弹层（按分类渲染按钮）

/// 扫码失败弹层：区分「可重试」「需刷新二维码」「需人工」「需登录」（D-011-2 §4.3）。
struct VehicleBindingScanFailureSheet: View {
    let failure: VehicleBindingFailure
    let onRetry: () -> Void
    let onRescan: () -> Void
    let onLogin: () -> Void
    let onDismiss: () -> Void

    private var action: ScanFailureAction { failure.scanFailureAction }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("vehicle_binding_alert_title")
                .font(AppTheme.fonts.title1)
                .foregroundColor(AppTheme.colors.fontPrimary)
            Text(LocalizedStringKey(failure.localizationKey))
                .font(AppTheme.fonts.subtext)
                .foregroundColor(AppTheme.colors.fontSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if action.allowsRetry {
                primaryButton(title: "vehicle_binding_retry", action: onRetry)
                secondaryButton(title: "vehicle_binding_cancel", action: onDismiss)
            } else if action.allowsLogin {
                primaryButton(title: "vehicle_binding_go_login", action: onLogin)
                secondaryButton(title: "vehicle_binding_cancel", action: onDismiss)
            } else if action.allowsRescan {
                primaryButton(title: "vehicle_binding_rescan", action: onRescan)
                secondaryButton(title: "vehicle_binding_alert_ok", action: onDismiss)
            } else {
                // 需人工（含 SGW-403001 禁止重试/禁止引导登录）：只给「我知道了」
                primaryButton(title: "vehicle_binding_alert_ok", action: onDismiss)
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .background(AppTheme.colors.background.ignoresSafeArea())
        .presentationDetents([.height(240)])
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(LocalizedStringKey(title))
                .font(AppTheme.fonts.title1)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.colors.brandMain)
                .clipShape(Capsule())
        }
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(LocalizedStringKey(title))
                .font(AppTheme.fonts.subtext)
                .foregroundColor(AppTheme.colors.fontTertiary)
                .frame(maxWidth: .infinity)
        }
    }
}
