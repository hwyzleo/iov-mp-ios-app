//
//  AvatarImage.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Kingfisher

struct AvatarImage: View {
    var avatar: String?
    var width: CGFloat = 50.0

    var body: some View {
        if let url = AvatarImage.validURL(avatar) {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .aspectRatio(contentMode: .fit)
        } else {
            Image("MyPlaceHolder")
                .resizable()
                .frame(width: width, height: width)
        }
    }

    /// 空串 / 非法 URL 回退占位图，避免强制解包崩溃（RD-003-9）
    static func validURL(_ avatar: String?) -> URL? {
        guard let avatar = avatar else { return nil }
        let trimmed = avatar.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let url = URL(string: trimmed), let scheme = url.scheme, !scheme.isEmpty else { return nil }
        return url
    }
}

struct AvatarImage_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImage()
    }
}
