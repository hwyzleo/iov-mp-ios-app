//
//  ErrorTip.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct ErrorTip: View {
    let text: String
    @State var time = 0.0
    var duration = 3.0
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(text)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .transition(.opacity)
                    .opacity(time == duration ? 0 : 1)
            }
            .padding(.bottom, 50)
        }
        .onAppear(perform: {
            withAnimation (.easeOut(duration: duration).delay(3)) {
                self.time = duration
            }
        })
    }
}

struct ErrorTip_Previews: PreviewProvider {
    static var previews: some View {
        ErrorTip(text: "错误提示", duration: 60)
    }
}
