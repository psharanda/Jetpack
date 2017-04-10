//
//  Created by Pavel Sharanda on 26.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

extension RetriableTaskHolder {
    
    @discardableResult
    public func retry(_ numberOfTimes: Int, timeout: TimeInterval? = nil, queue: DispatchQueue = DispatchQueue.main, f: @escaping (T)->Bool) -> RetriableTaskHolder<T> {
        var numberOfRetries = 0
        var cancellableClosure: (()->Void)?
        
        retry({ (value, resulter) in
            
            numberOfRetries += 1
            
            if numberOfRetries - 1 < numberOfTimes  {
                if let timeout = timeout {
                    cancellableClosure = JetPackUtils.after(timeout, queue: queue) {
                        resulter(f(value))
                    }
                } else {
                    resulter(f(value))
                }
            }
            
        }) {
            numberOfRetries = 0
            cancellableClosure?()
            cancellableClosure = nil
        }
        
        return self
    }
    
}
