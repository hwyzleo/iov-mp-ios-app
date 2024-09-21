//
//  CircularImageButton.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/21.
//

import SwiftUI

struct CircularImageButton: View {
    var icon: String
    var iconSize: CGFloat = 20
    var name: String
    @Binding var isLoading: Bool
    @State private var progress: CGFloat = 0
    @State private var isCountdownActive: Bool = false
    @Binding var duration: Double
    var action: (() -> Void)?
    
    @State private var timer: Timer?
    @State private var internalDuration: Double = 0
    
    var body: some View {
        VStack {
            ZStack {
                CircularProgressView(progress: progress, isActive: isCountdownActive)
                    .frame(width: 45, height: 45)
                Button(action: {
                    if !isLoading && !isCountdownActive {
                        action?()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1)
                    } else {
                        Image(icon)
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
                .frame(width: 45, height: 45)
                .background(isLoading || isCountdownActive ? Color(hex: 0xCCCCCC) : Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black, radius: 1, x: 0, y: 0)
                .buttonStyle(.plain)
            }
            Spacer()
                .frame(height: 15)
            
            Text(name)
                .font(.system(size: 14))
        }
        .onChange(of: duration) { newValue in
            print("Duration changed to: \(newValue)")
            if newValue > 0 {
                internalDuration = newValue
                startCountdown()
            }
        }
    }
    
    private func startCountdown() {
        progress = 0
        isCountdownActive = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation {
                progress += 0.1 / internalDuration
            }
            if progress >= 1 {
                timer?.invalidate()
                isCountdownActive = false
                progress = 0
            }
        }
    }
}

struct CircularProgressView: View {
    var progress: CGFloat
    var isActive: Bool
    
    var body: some View {
        Circle()
            .trim(from: 0, to: isActive ? progress : 1)
            .stroke(
                isActive ?
                    LinearGradient(gradient: Gradient(colors: [.green]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(gradient: Gradient(colors: [.clear]), startPoint: .topLeading, endPoint: .bottomTrailing),
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
    }
}

struct CircularImageButtonPreview: View {
    @State private var duration: Double = 0
    @State private var isLoading = false

    var body: some View {
        VStack {
            CircularImageButton(
                icon: "icon_vehicle_search",
                name: "寻车",
                isLoading: $isLoading,
                duration: $duration
            )
            
            Button("开始10秒倒计时") {
                duration = 0
                isLoading = true
            }
            
            Button("重置倒计时") {
                duration = 10
                isLoading = false
            }
            
            Button("切换加载状态") {
                isLoading.toggle()
            }
        }
    }
}

#Preview {
    CircularImageButtonPreview()
}
