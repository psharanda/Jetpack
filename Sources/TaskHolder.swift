//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

///special observable which holds reference to task and is able to cancel it
public class TaskHolder<T>: Observable<T>, Cancelable {
    
    internal var task: Task<T>?
    
    public func cancel() {
        task = nil
    }
}
