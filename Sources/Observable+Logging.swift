//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension ObserveValueProtocol {
    
    public func log(_ tag: String? = nil) -> Observable<ValueType> {
        let s = tag ?? "\(ValueType.self)"
        return forEach {
            Swift.print("\(s): \($0)")
        }
    }
    
    public func dump(_ tag: String? = nil) -> Observable<ValueType> {
        let s = tag ?? "\(ValueType.self)"
        return forEach {
            Swift.print("\(s):")
            _ = Swift.dump($0)
        }
    }
    
}
