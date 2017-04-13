//
//  Created by Pavel Sharanda on 06.04.17.
//  Copyright © 2017 Task. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    private typealias Cancelation = () -> Void
    
    private class DispatchQueueDisposable: Disposable {
        private var cancelableClosure: DispatchQueue.Cancelation?
        
        init(cancelableClosure: @escaping DispatchQueue.Cancelation) {
            self.cancelableClosure = cancelableClosure
        }
        
        func dispose() {
            cancelableClosure?()
            cancelableClosure = nil
        }
    }
    
    @discardableResult
    public func after(timeInterval: TimeInterval, action: @escaping (Bool)->Void) ->  Disposable {
        var closure = Optional.some(action)
        
        let cancelableClosure = {
            let tmp = closure
            closure = nil
            self.async {
                tmp?(true)
            }
        }
        
        asyncAfter(deadline: .now() + timeInterval) {
            closure?(false)
        }
        
        return DispatchQueueDisposable(cancelableClosure: cancelableClosure);
    }
    
    @discardableResult
    public func run<T>(worker: @escaping ()->TaskResult<T>, completionQueue: DispatchQueue = .main, completion: @escaping (TaskResult<T>)->Void) -> Disposable {
        var cancelled = false
        
        let cancelableClosure = {
            cancelled = true
        }
        
        async {
            if !cancelled {
                let result = worker()
                completionQueue.async {
                    if !cancelled {
                        completion(result)
                    } else {
                        completion(.cancelled)
                    }
                }
            } else {
                completionQueue.async {
                    completion(.cancelled)
                }
            }
        }
        
        return DispatchQueueDisposable(cancelableClosure: cancelableClosure);
    }
}
