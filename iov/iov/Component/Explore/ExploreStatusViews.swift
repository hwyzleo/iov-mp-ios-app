//
//  ExploreStatusViews.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/27.
//

import SwiftUI

/// 空态 / 错误态 / 不可用态统一容器
struct ExploreStatusView: View {
    let icon: String
    let message: LocalizedStringKey
    let actionTitle: LocalizedStringKey
    var iconColor: Color = ExploreTheme.Colors.brand
    let action: () -> Void

    var body: some View {
        VStack(spacing: ExploreTheme.Layout.spacing) {
            ZStack {
                Circle()
                    .fill(ExploreTheme.Colors.surface2)
                Circle()
                    .strokeBorder(ExploreTheme.Colors.border, lineWidth: 1)
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(iconColor)
            }
            .frame(width: 72, height: 72)

            Text(message)
                .font(ExploreTheme.Fonts.body)
                .foregroundColor(ExploreTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, ExploreTheme.Layout.margin)

            Button(action: action) {
                Text(actionTitle)
            }
            .buttonStyle(ExploreSecondaryButtonStyle())
            .frame(maxWidth: 240)
        }
        .padding(ExploreTheme.Layout.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ExploreTheme.Colors.background)
    }
}

/// 非阻塞错误条：不清空已加载内容
struct ExploreInlineErrorBanner: View {
    let message: LocalizedStringKey
    let canRetry: Bool
    let onRetry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ExploreTheme.Colors.warning)

            Text(message)
                .font(ExploreTheme.Fonts.caption)
                .foregroundColor(ExploreTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            if canRetry {
                Button(action: onRetry) {
                    Text(L10n.explore_retry)
                        .font(ExploreTheme.Fonts.caption.weight(.semibold))
                        .foregroundColor(ExploreTheme.Colors.brand)
                }
                .buttonStyle(.plain)
            }

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ExploreTheme.Colors.textTertiary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(L10n.explore_dismiss))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(ExploreTheme.Colors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: ExploreTheme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ExploreTheme.Radius.card, style: .continuous)
                .strokeBorder(ExploreTheme.Colors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 4)
    }
}

extension ExplorePresentationError {
    var messageKey: LocalizedStringKey {
        switch self {
        case let .refresh(failure):
            return failure.localizedKey
        case let .feed(_, failure):
            return failure.localizedKey
        case let .target(failure):
            return failure.localizedKey
        }
    }

    var canRetry: Bool {
        if case .target = self { return false }
        return true
    }
}
