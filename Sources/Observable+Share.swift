//
//  Created by Pavel Sharanda on 17.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension ObservableProtocol {
    
    public func shareReplay(_ count: Int = 1) -> (Observable<ValueType>, Disposable) {
        let replayer = ReplaySubject<ValueType>(bufferSize: count)
        return (replayer.asObservable, bind(replayer))
    }
    
    public func shareReplay(_ count: Int = 1, disposeIn bag: DisposeBag) -> Observable<ValueType> {
        let (observer, d) = shareReplay()
        bag.add(d)
        return observer
    }
}
