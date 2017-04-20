//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension Observable {
    
    public func buffer(timeInterval: TimeInterval, maxSize: Int = Int.max, queue: DispatchQueue = DispatchQueue.main) -> Observer<[ValueType]> {
        var buf = [ValueType]()
        var lastAfterCancel: Disposable? = nil
        
        return Observer { observer in
            
            func after() {
                lastAfterCancel?.dispose()
                lastAfterCancel = queue.jx_after(timeInterval: timeInterval) {
                    if buf.count > 0 {
                        observer(buf)
                        buf.removeAll()
                    }
                    after()
                }
            }
            
            after()
            
            return self.subscribe { result in
                buf.append(result)
                if buf.count >= maxSize {
                    observer(buf)
                    buf.removeAll()
                    after()
                }
            }.with(disposable: DelegateDisposable {
                lastAfterCancel?.dispose()
                lastAfterCancel = nil
            })
        }
    }
    
}
