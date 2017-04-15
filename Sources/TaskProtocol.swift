//
//  TaskProtocol.swift
//  Jetpack
//
//  Created by Pavel Sharanda on 12.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

public protocol TaskProtocol {
    associatedtype ResultValueType
    func start(_ completion: @escaping (Result<ResultValueType>) -> Void) -> Disposable
}

extension TaskProtocol {
    public var asObserver: Observer<Result<ResultValueType>> {
        return Observer { observer in
            return self.start(observer)
        }
    }
}

extension Observable where ValueType: ErrorConvertible & ValueConvertible {
    public var asTask: Task<ValueType.ValueType> {
        return Task { completion in
            return self.subscribe { result in
                if let value = result.value {
                    completion(.success(value))
                } else if let error = result.error {
                    completion(.failure(error))
                }
            }
        }
    }
}
