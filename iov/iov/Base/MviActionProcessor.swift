//
//  MviActionProcessor.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

class MviActionProcessor<A: MviModelActionProtocol, S: MviModelStateProtocol> {
    
    func executeAction(action: A, state: S){
        fatalError("方法未实现")
    }
    
}
