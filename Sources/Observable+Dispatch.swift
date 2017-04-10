//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension Observable {
    
    public func dispatch(in queue: DispatchQueue) -> Observer<ValueType> {
        return Observer { observer in
            return self.subscribe { result in
                queue.async {
                    observer(result)
                }
            }
        }
    }
}
