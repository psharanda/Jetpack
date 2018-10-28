//
//  Created by Pavel Sharanda
//  Copyright (c) 2016. All rights reserved.
//

import Foundation

/// Base interface to observe value changes over time (`subscribe`)
public protocol ObservableProtocol {
    associatedtype ValueType
    func subscribe(_ observer: @escaping (ValueType) -> Void) -> Disposable
}

extension ObservableProtocol {
    @discardableResult
    public func subscribe() -> Disposable {
        return subscribe {_ in }
    }
}

