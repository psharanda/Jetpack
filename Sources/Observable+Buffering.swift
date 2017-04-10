//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

extension Observable {
    
    @discardableResult
    public func buffer(timeInterval: TimeInterval, maxSize: Int = Int.max, queue: DispatchQueue = DispatchQueue.main) -> Observable<[T]> {
        let signal = Signal<[T]>()
        var buf = [T]()
        
        var lastAfterCancel: (()->Void)? = nil
        
        func after() {
            lastAfterCancel?()
            lastAfterCancel = JetPackUtils.after(timeInterval, queue: queue) { [weak signal] in
                guard let signal = signal else { return }
                signal.update(buf)
                buf.removeAll()
                after()
            }
        }
        
        subscribe { result in
            buf.append(result)
            if buf.count >= maxSize {
                signal.update(buf)
                buf.removeAll()
                after()
            }
        }
        
        after()
        
        return signal
    }
    
}
