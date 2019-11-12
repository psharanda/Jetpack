//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension ObserveValueProtocol {
    
    public func throttle(timeInterval: TimeInterval, on queue: DispatchQueue, latest: Bool = true) -> Observable<ValueType> {
        return Observable { observer in
            
            var lastUpdateTime = Date.distantPast
            var lastIgnoredValue: ValueType?
            var lastAfterDisposable = SwapableDisposable()
            
            return self.subscribe { result in
                let newDate = Date()
                lastIgnoredValue = result
                if newDate.timeIntervalSince(lastUpdateTime) >= timeInterval {
                    lastUpdateTime = newDate
                    lastIgnoredValue = nil
                    lastAfterDisposable.dispose()
                    observer(result)                    
                    if latest {
                        func handleLatest() {
                            lastAfterDisposable.swap(with: queue.jx_asyncAfter(deadline: .now() + timeInterval) {
                                if let lastIgnoredValue = lastIgnoredValue {
                                    observer(lastIgnoredValue)
                                    lastUpdateTime = Date()
                                }
                                lastIgnoredValue = nil
                                handleLatest()
                            })
                        }                        
                        handleLatest()
                    }
                }
            }.with(disposable: lastAfterDisposable)
        }
    }

    public func debounce(timeInterval: TimeInterval, on queue: DispatchQueue) -> Observable<ValueType> {
        return Observable { observer in
            let lastAfterCancel = SwapableDisposable()
            return self.subscribe { result in
                lastAfterCancel.swap(with: queue.jx_asyncAfter(deadline: .now() + timeInterval) {
                    observer(result)
                })
            }.with(disposable: lastAfterCancel)
        }
    }
}



