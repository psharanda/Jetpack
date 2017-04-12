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
    public var resultObserver: Observer<Result<ValueType>> {
        return Observer { observer in
            return self.start { result in
                if let r = result.result {
                    observer(r)
                }
            }
        }
    }
    
    public var taskResultObserver: Observer<TaskResult<ValueType>> {
        return Observer { observer in
            return self.start(observer)
        }
    }
}
