//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// Wrapper around some deffered, cancellable work which produces value and will be executed in the future ('subscribe')
public final class Observable<T>: ObservableProtocol {
    
    public typealias ValueType = T
    
    private let generator: (@escaping (T) -> Void) -> Disposable
    
    
    public init(_ generator: @escaping (@escaping (T) -> Void) -> Disposable) {
        self.generator = generator
    }
    
    @available(*, deprecated, renamed: "init(_:)", message: "Please use init(_:) instead")
    public init(generator: @escaping (@escaping (T) -> Void) -> Disposable) {
        self.generator = generator
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return generator(observer)
    }
}

extension ObservableProtocol {
    public var asObservable: Observable<ValueType> {
        return Observable { observer in
            return self.subscribe(observer)
        }
    }
}



