//
//  Created by Pavel Sharanda
//  Copyright (c) 2016. All rights reserved.
//

import Foundation

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

