//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

enum JetPackUtils {
    
    static func after(_ timeInterval: TimeInterval, queue: DispatchQueue = DispatchQueue.main, block: @escaping ()->Void) ->  (() -> Void) {
        
        var closure: (()->Void)? = block
        
        let cancelableClosure = {
            closure = nil
        }
        
        queue.asyncAfter(deadline: .now() + timeInterval) {
            closure?()
        }
        
        return cancelableClosure;
    }
}
