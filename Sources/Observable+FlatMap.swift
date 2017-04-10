//
//  Created by Pavel Sharanda on 20.03.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation


extension Observable {
    
    public func flatMapLatest<U: Observable>(_ f: @escaping ((ValueType) -> U)) -> Observer<U.ValueType> {
        return Observer<U.ValueType> { observer in
            let serial = SerialDisposable()
            
            serial.swap(with: self.subscribe { result in
                serial.dispose()
                serial.swap(with: f(result).subscribe(observer))
            })
            return serial
        }
    }
    
    public func flatMapMerge<U: Observable>(_ f: @escaping ((ValueType) -> U)) -> Observer<U.ValueType> {
        return Observer<U.ValueType> { observer in
            let multi = MultiDisposable()
            
            multi.add(self.subscribe { result in
                multi.add(f(result).subscribe(observer))
            })
            return multi
        }
    }
}

