//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

public class RetriableTaskHolder<T>: TaskHolder<T> {
    
    internal var taskCreator: (()->Task<T>?)? {
        didSet {
            cancel()
            recreateTask()
        }
    }
    
    private func recreateTask() {
        
        task = taskCreator?()
        
        task?.subscribe {[weak self] innerResult in
            self?.rawUpdate(innerResult)
        }
        
        task?.completion.subscribe {[weak self] completed in
            guard let strongSelf = self else { return }
            strongSelf.task = nil
            if case .finished = completed {
                strongSelf.retryTaskIfNeeded()
            }
        }
    }
    
    public override func cancel() {
        super.cancel()
        cancelationHandler?()
    }
    
    private func retryTaskIfNeeded() {
        if let value = lastValue,
            let checker = checker {
            
            checker(value) {[weak self] shouldRetry in
                if shouldRetry {
                    self?.recreateTask()
                }
            }
            
        }
    }
    
    private var checker: ((T, @escaping (Bool)->Void) -> Void )?
    private var cancelationHandler: (()->Void)?
    
    @discardableResult
    public func retry(_ checker: @escaping (T, @escaping (Bool)->Void) -> Void, cancelationHandler:  (()->Void)? = nil) -> RetriableTaskHolder<T> {
        self.checker = checker
        self.cancelationHandler = cancelationHandler
        return self
    }
}
