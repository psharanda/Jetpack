//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

enum JetPackUtils {
    
    static func after(_ timeInterval: TimeInterval, queue: DispatchQueue = DispatchQueue.main, block: @escaping ()->Void) ->  (() -> Void) {
        
        func dispatch_later(_ block:@escaping ()->Void) {
            queue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
        }
        
        var closure: (()->Void)? = block
        
        let cancelableClosure = {
            closure = nil
        }
        
        dispatch_later {
            closure?()
        }
        
        return cancelableClosure;
    }
}
