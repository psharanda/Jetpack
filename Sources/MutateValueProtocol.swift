//
//  Created by Pavel Sharanda on 10/5/19.
//  Copyright © 2019 Jetpack. All rights reserved.
//

import Foundation

/// Base interface to mutate current value (`get+set`)
public protocol MutateValueProtocol {
    associatedtype MutateValueType
    
    func mutate(_ transform: (inout MutateValueType) -> ())
}




