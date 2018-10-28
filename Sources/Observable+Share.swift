//
//  Created by Pavel Sharanda on 17.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension ObservableProtocol {
    public func shareReplay(_ bufferSize: Int = 1) -> Observable<ValueType> {
        var replaySubject: ReplaySubject<ValueType>?
        var refCount: Int = 0
        var disposable: Disposable?
        
        return Observable { observer in
            if disposable == nil {
                replaySubject = ReplaySubject<ValueType>(bufferSize: bufferSize)
                disposable = self.bind(replaySubject!)
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
            }
        }
    }
}
