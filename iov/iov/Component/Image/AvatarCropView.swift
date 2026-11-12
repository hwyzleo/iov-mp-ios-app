//
//  AvatarCropView.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-003 on 2026/11/12.
//

import SwiftUI
import Photos

/// 头像裁剪界面（IOS-APP-DSN-CR-003 RD-003-2 / US-003-1）
/// 固定正方形裁剪框：单指拖动、双指缩放、重置、取消；确认后返回裁剪参数。
struct AvatarCropView: View {

    let image: UIImage
    var onCancel: () -> Void
    var onConfirm: (AvatarCropInput) -> Void

    /// 裁剪框边长（视图单位）
    var cropSide: CGFloat = 280

    @State private var zoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var dragOrigin: CGSize = .zero
    @State private var zoomOrigin: CGFloat = 1
    @State private var errorText: String?

    private var imageSize: CGSize { image.size }
    private var baseScale: CGFloat { CropGeometry.minimumScale(imageSize: imageSize, cropSide: cropSide) }
    private var effectiveScale: CGFloat { baseScale * zoom }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: kStatusBarHeight)
            TopCloseTitleBar(title: "调整头像") {
                onCancel()
            }

            Spacer(minLength: 24)

            cropArea

            Text("拖动调整位置，双指缩放")
                .font(AppTheme.fonts.subtext)
                .foregroundColor(AppTheme.colors.fontSecondary)
                .padding(.top, 16)

            if let errorText = errorText {
                Text(errorText)
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.brandMain)
                    .padding(.top, 8)
            }

            HStack(spacing: 12) {
                Button(action: reset) {
                    Text("重置")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .background(AppTheme.colors.cardBackground)
                        .cornerRadius(22)
                }
                .buttonStyle(.plain)

                Button(action: confirm) {
                    Text("确定")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .foregroundColor(.black)
                        .background(AppTheme.colors.brandMain)
                        .cornerRadius(22)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.layout.margin)
            .padding(.top, 24)

            Spacer()
        }
        .appBackground()
        .onAppear(perform: reset)
    }

    private var cropArea: some View {
        ZStack {
            Color.black
            Image(uiImage: image)
                .resizable()
                .frame(width: imageSize.width * effectiveScale, height: imageSize.height * effectiveScale)
                .offset(x: offset.width, y: offset.height)
        }
        .frame(width: cropSide, height: cropSide)
        .clipped()
        .overlay(
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
        )
        .overlay(cropGrid)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .simultaneousGesture(magnificationGesture)
    }

    private var cropGrid: some View {
        GeometryReader { _ in
            Path { path in
                let step = cropSide / 3
                for index in 1...2 {
                    let position = step * CGFloat(index)
                    path.move(to: CGPoint(x: position, y: 0))
                    path.addLine(to: CGPoint(x: position, y: cropSide))
                    path.move(to: CGPoint(x: 0, y: position))
                    path.addLine(to: CGPoint(x: cropSide, y: position))
                }
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let proposed = CGSize(
                    width: dragOrigin.width + value.translation.width,
                    height: dragOrigin.height + value.translation.height
                )
                offset = CropGeometry.clampOffset(
                    proposed,
                    imageSize: imageSize,
                    cropSide: cropSide,
                    scale: effectiveScale
                )
            }
            .onEnded { _ in
                dragOrigin = offset
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                zoom = min(max(zoomOrigin * value, 1), 4)
                offset = CropGeometry.clampOffset(
                    offset,
                    imageSize: imageSize,
                    cropSide: cropSide,
                    scale: effectiveScale
                )
                dragOrigin = offset
            }
            .onEnded { _ in
                zoomOrigin = zoom
            }
    }

    private func reset() {
        zoom = 1
        zoomOrigin = 1
        offset = .zero
        dragOrigin = .zero
        errorText = nil
    }

    private func confirm() {
        guard imageSize.width > 0, imageSize.height > 0 else {
            errorText = "图片读取失败，请重新选择"
            return
        }
        let input = AvatarCropInput(
            image: image,
            cropSide: cropSide,
            scale: effectiveScale,
            offset: offset
        )
        onConfirm(input)
    }
}

/// 相册权限（仅相册入口；拒绝时引导到系统设置）
enum AvatarPhotoPermission {
    static func requestIfNeeded(_ completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }
}

struct AvatarCropView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarCropView(image: UIImage(), onCancel: {}, onConfirm: { _ in })
    }
}
