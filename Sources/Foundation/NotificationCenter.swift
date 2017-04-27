//
//  Created by Pavel Sharanda on 14.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation


extension JetpackExtensions where Base: NotificationCenter {
    
    public func observer(forName name: NSNotification.Name) -> Observer<(object: Any?, userInfo: [AnyHashable: Any]?)> {
        return base.jx_lazyObject(key: name.rawValue) { () -> NotificationHandler in
            return NotificationHandler(notificationCenter: base, notificationName: name)
        }.signal.asObserver
    }
}


private class NotificationHandler: NSObject {
    
    let signal = Signal<(object: Any?, userInfo: [AnyHashable: Any]?)>()
    weak var notificationCenter: NotificationCenter?
    let notificationName: NSNotification.Name
    
    init(notificationCenter: NotificationCenter, notificationName: NSNotification.Name) {
        self.notificationCenter = notificationCenter
        self.notificationName = notificationName
        super.init()
        notificationCenter.addObserver(self, selector: #selector(handleNotification(notification:)), name: notificationName, object: nil)
    }
    
    @objc private func handleNotification(notification: NSNotification) {
        signal.update((notification.object, notification.userInfo))
    }
    
    deinit {
        notificationCenter?.removeObserver(self, name: notificationName, object: nil)
    }
}
