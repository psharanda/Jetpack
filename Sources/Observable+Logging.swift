//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

extension Observable {
    
    @discardableResult
    public func log(_ tag: String? = nil) -> Observable<T> {
        let signal = Signal<T>()
        
        let s = tag ?? "\(signal)"
        subscribe { result in
            Swift.print("\(s): \(result)")
            signal.update(result)
        }
        return signal
    }
    
    @discardableResult
    public func dump(_ tag: String? = nil) -> Observable<T> {
        let signal = Signal<T>()
        
        let s = tag ?? "\(signal)"
        subscribe { result in
            Swift.print("\(s):")
            _ = Swift.dump(result)
            signal.update(result)
        }
        return signal
    }
    
}
