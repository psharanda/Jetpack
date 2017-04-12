//
//  Created by Pavel Sharanda on 12.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

public enum Either<T, U> {
    case left(T)
    case right(U)
}
