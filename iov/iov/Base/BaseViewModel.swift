//
//  BaseViewModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

class BaseViewModel<I: MviIntentProtocol, A: MviModelActionProtocol, S: MviModelStateProtocol>: ObservableObject {
    
    // 状态
    @Published var viewState: S
    
    init (viewState: S) {
        self.viewState = viewState
    }
    
    func dispatch(intent: I){
        fatalError("方法未实现")
    }
    
    func actionFromIntent(intent: I) -> A {
        fatalError("方法未实现")
    }
    
    func executeAction(action: A) {
        fatalError("方法未实现")
    }

}
