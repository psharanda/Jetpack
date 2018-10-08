//
//  Created by Pavel Sharanda on 17.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension ObservableProtocol {
    
    public func shareReplay(_ count: Int) -> (Observable<ValueType>, Disposable) {
        let replayer = Replayer<ValueType>(bufferSize: count)
        return (replayer.asObservable, bind(replayer))
        
    }
    
    public func share() -> (Observable<ValueType>, Disposable) {
        return shareReplay(1)
    }
    
    public func share(autodisposeIn pool: AutodisposePool) -> Observable<ValueType> {
        let (observer, d) = share()
        pool.add(d)
        return observer
    }
    
    public func share(autodisposeIn box: AutodisposeBox) -> Observable<ValueType> {
        let (observer, d) = share()
        box.put(d)
        return observer
    }
}
