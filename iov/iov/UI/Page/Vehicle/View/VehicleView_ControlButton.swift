//
//  VehicleView_ControlButton.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension VehicleView {
    struct ControlButton: View {
        var icon: String
        var iconSize: CGFloat = 20
        var name: String
        @Binding var isLoading: Bool
        var action: (() -> Void)?
        var body: some View {
            VStack {
                Button(action: {
//                    isLoading = true
                    action?()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: iconSize))
                    }
                }
                .frame(width: 45, height: 45)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                .buttonStyle(.plain)
                Spacer()
                    .frame(height: 15)
                Text(name)
                    .font(.system(size: 14))
            }
        }
    }
}


#Preview {
    VehicleView.ControlButton(icon: "lock", name: "车锁", isLoading: .constant(false))
}
