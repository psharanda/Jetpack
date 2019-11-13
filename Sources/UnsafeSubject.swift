//
//  UnsafeSubject.swift
//  Jetpack
//
//  Created by Pavel Sharanda on 10/11/19.
//  Copyright © 2019 Jetpack. All rights reserved.
//

import Foundation

final class UnsafeSubject<T> {

    private struct ObserverHolder<T> {
        let token: UInt
        let observer: (T) -> Void
    }
    
    private var observers: [ObserverHolder<T>] = []
    private var lastToken: UInt = 0
    
    func update(_ newValue: T) {
        observers.forEach {
            $0.observer(newValue)
        }
    }
    
    func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        
        let token = lastToken
        observers.append(ObserverHolder<T>(token: token, observer: observer))
        lastToken += 1
        
        return BlockDisposable {
            guard let idx = (self.observers.firstIndex { $0.token == token }) else {
                return
            }
            self.observers.remove(at: idx)
        }
    }
}



