//
//  Created by Pavel Sharanda
//  Copyright (c) 2016. All rights reserved.
//

import Foundation

public protocol Observable {
    associatedtype ValueType
    func subscribe(_ observer: @escaping (ValueType) -> Void) -> Disposable
}



