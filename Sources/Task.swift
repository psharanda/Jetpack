//
//  Created by Pavel Sharanda and Yuras Shumovich
//  Copyright © 2017. All rights reserved.
//

import Foundation

public typealias Task<T> = Observable<Result<T>>


extension Task {
    
    /**
     Create task which immediately completes with value
     */
    public static func from<U>(value: U) -> Task<U>  where T == Result<U> {
        return from(.success(value))
    }
    
    /**
     Create task which immediately completes with error
     */
    public static func from<U>(error: Error) -> Task<U>  where T == Result<U> {
        return from(.failure(error))
    }
}

