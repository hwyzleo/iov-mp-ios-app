//
//  LoadingTip.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct LoadingTip: View {
    var text: String = "Loading"
    
    var body: some View {
        ZStack {
            Color.white
            Text(text)
        }
    }
}

struct LoadingTip_Previews: PreviewProvider {
    static var previews: some View {
        LoadingTip()
    }
}
