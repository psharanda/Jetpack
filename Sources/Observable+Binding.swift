//
//  Created by Pavel Sharanda on 10/5/19.
//  Copyright © 2019 Jetpack. All rights reserved.
//

import Foundation

extension ObserveValueProtocol {
    
    public func bind<T: UpdateValueProtocol>(to bindable: T) -> Disposable where T.UpdateValueType == ValueType {
        return subscribe { result in
            bindable.update(result)
        }
    }
    
    public func bind<T: UpdateValueProtocol>(to bindable: T) -> Disposable where T.UpdateValueType == ValueType? {
        return subscribe { result in
            bindable.update(result)
        }
    }
    
    
    public func bind<T: MutateValueProtocol>(to bindable: T, reduce: @escaping (inout T.MutateValueType, ValueType) -> Void ) -> Disposable {
        return subscribe { result in
            bindable.mutate {
                reduce(&$0, result)
            }
        }
    }
    
    public func bind<T: MutateValueProtocol>(to bindable: T, keyPath: WritableKeyPath<T.MutateValueType, ValueType>) -> Disposable {
        return bind(to: bindable) {
            $0[keyPath: keyPath] = $1
        }
    }
}

