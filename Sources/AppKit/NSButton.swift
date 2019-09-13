//
//  Created by Pavel Sharanda on 8/17/19.
//  Copyright © 2019 Jetpack. All rights reserved.
//

#if os(macOS)

import Cocoa

extension JetpackExtensions where Base: NSButton {
    
    public var clicked: Observable<Void> {
        return jx_makeTargetActionSubject(key: #function, setup: { base, target, action in
            base.target = target
            base.action = action
        }, cleanup: { base, _, _ in
            base.target = nil
            base.action = nil
        }, getter: { _ in
            ()
        }).asObservable
    }
}

#endif
