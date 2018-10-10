//
//  Created by Pavel Sharanda on 06.04.17.
//  Copyright © 2017 Task. All rights reserved.
//

import Foundation


extension JetpackExtensions where Base: DispatchQueue {

    @discardableResult
    public func after(timeInterval: TimeInterval, action: @escaping ()->Void) ->  Disposable {
        var closure = Optional.some(action)
        
        let cancelableClosure = {
            closure = nil
        }
        
        base.asyncAfter(deadline: .now() + timeInterval) {
            closure?()
        }
        
        return BlockDisposable { cancelableClosure() }
    }
    
    @discardableResult
    public func async(action: @escaping ()->Void) ->  Disposable {
        var closure = Optional.some(action)
        
        let cancelableClosure = {
            closure = nil
        }
        
        base.async {
            closure?()
        }
        
        return BlockDisposable { cancelableClosure() }
    }
    
    @discardableResult
    public func execute<T>(worker: @escaping ()->T, completionQueue: DispatchQueue = .main, completion: @escaping (T)->Void) -> Disposable {
        var cancelled = false
        
        let cancelableClosure = {
            cancelled = true
        }
        
        base.async {
            if !cancelled {
                let result = worker()
                completionQueue.async {
                    if !cancelled {
                        completion(result)
                    }
                }
            }
        }
        
        return BlockDisposable { cancelableClosure() }
    }
}

