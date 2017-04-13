//
//  TaskProtocol.swift
//  Jetpack
//
//  Created by Pavel Sharanda on 12.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

public protocol TaskProtocol {
    associatedtype ValueType
    func start(_ completion: @escaping (TaskResult<ValueType>) -> Void) -> Disposable
}

extension TaskProtocol {
    public var asObserver: Observer<Result<ValueType>> {
        return Observer { observer in
            return self.start { result in
                if let r = result.result {
                    observer(r)
                }
            }
        }
    }
    
    public var asTaskObserver: Observer<TaskResult<ValueType>> {
        return Observer { observer in
            return self.start(observer)
        }
    }
    
    public var asTask: Task<ValueType> {
        return Task { completion in
            return self.start(completion)
        }
    }
}
