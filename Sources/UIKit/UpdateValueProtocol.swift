//
//  Created by Pavel Sharanda on 30.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

public protocol UpdateValueProtocol {
    associatedtype UpdateValueType
    func update(_ newValue: UpdateValueType)
}

extension UpdateValueProtocol where UpdateValueType == Void {
    public func update() {
        update(())
    }
}


