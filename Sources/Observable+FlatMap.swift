//
//  Created by Pavel Sharanda on 20.03.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation


extension ObservableProtocol {
    
    public func flatMapLatest<U>(_ f: @escaping ((ValueType) -> Observable<U>)) -> Observable<U> {
        return Observable<U> { observer in
            let serial = SwapableDisposable()
            serial.swap(parent: self.subscribe { result in
                serial.disposeChild()                
                serial.swap(child: f(result).subscribe(observer))
            })
            return serial
        }
    }
    
    public func flatMapMerge<U>(_ f: @escaping ((ValueType) -> Observable<U>)) -> Observable<U> {
        return Observable<U> { observer in
            let multi = MultiDisposable()
            
            multi.add(self.subscribe { result in
                multi.add(f(result).subscribe(observer))
            })
            return multi
        }
    }
}

