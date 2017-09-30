//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public extension ObservableProtocol {
    
    public func bind<T: UpdateValueProtocol>(_ bindable: T) -> Disposable where T.UpdateValueType == ValueType {
        return subscribe {result in
            bindable.update(result)
        }
    }
    
    public func bind<T: UpdateValueProtocol>(_ bindable: T) -> Disposable where T.UpdateValueType == ValueType? {
        
        return subscribe { result in
            bindable.update(result)
        }
    }
}


