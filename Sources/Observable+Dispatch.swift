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
    
    /**
     Deliver value after delay
     */
    public func delay(timeInterval: TimeInterval, queue: DispatchQueue = .main) -> Observer<ValueType> {        
        return Observer { completion  in
            let serial = SerialDisposable()
            serial.swap(with: self.subscribe { result in
                serial.swap(with: queue.after(timeInterval: timeInterval) {
                    completion(result)
                })
            })
            return serial
        }
    }
}
