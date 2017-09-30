//
//  Created by Pavel Sharanda on 30.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

public protocol GetValueProtocol {
    associatedtype GetValueType
    var value: GetValueType {get}
}

