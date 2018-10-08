//
//  Created by Pavel Sharanda and Yuras Shumovich
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// This is just an agreement, that Observable which works with Result can be treated in special way, but no real obligations here.
public typealias Task<T> = Observable<Result<T>>


extension Task {
    
    /// Create task which immediately completes with value
    public static func just<U>(value: U) -> Task<U>  where T == Result<U> {
        return just(.success(value))
    }
    
    /// Create task which immediately completes with error
    public static func just<U>(error: Error) -> Task<U>  where T == Result<U> {
        return just(.failure(error))
    }
}

