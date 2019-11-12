//
//  Created by Pavel Sharanda on 17.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension ObserveValueProtocol {
    public func shareReplay(_ bufferSize: Int = 1) -> Observable<ValueType> {
        var replaySubject: ReplaySubject<ValueType>?
        var refCount = 0
        var disposable: Disposable?
        
        let lock = Lock()
        
        return Observable { observer in
            lock.synchronized {
                if disposable == nil {
                    replaySubject = ReplaySubject<ValueType>(bufferSize: bufferSize)
                    let newDisposable = self.subscribe { result in
                        replaySubject!.update(result)
                    }
                    
                    disposable = newDisposable
                }
                refCount += 1
                let subjectDisposable = replaySubject!.subscribe(observer)
                
                return BlockDisposable {
                    subjectDisposable.dispose()
                    refCount -= 1
                    if refCount == 0 {
                        disposable?.dispose()
                        disposable = nil
                        replaySubject = nil
                    }
                }.locked(with: lock)
            }
        }
    }
}
