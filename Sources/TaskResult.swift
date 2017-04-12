//
//  Created by Pavel Sharanda on 12.04.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

public enum TaskResult<T> {
    case success(T) //contains value
    case failure(Error) //contains error
    case cancelled
    
    public init(value: T) {
        self = .success(value)
    }
    
    public init(error: Error) {
        self = .failure(error)
    }
}

extension TaskResult {
    public var value: T? {
        switch self {
        case .success(let v):
            return v
        case .failure:
            return nil
        case .cancelled:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let e):
            return e
        case .cancelled:
            return nil
        }
    }
    
    public var isCancelled: Bool {
        switch self {
        case .success:
            return false
        case .failure:
            return false
        case .cancelled:
            return true
        }
    }
    
    public var result: Result<T>? {
        switch self {
        case .success(let v):
            return .success(v)
        case .failure(let e):
            return .failure(e)
        case .cancelled:
            return nil
        }
    }
}

extension TaskResult {
    public func map<U>(_ transform: (T) throws -> U) rethrows -> TaskResult<U> {
        switch self {
        case .success(let v):
            do {
                return try .success(transform(v))
            }
            catch {
                return .failure(error)
            }
        case .failure(let e):
            return .failure(e)
        case .cancelled:
            return .cancelled
        }
    }
    
    public func flatMap<U>(_ transform: (T) throws -> TaskResult<U>) rethrows -> TaskResult<U> {
        switch self {
        case .success(let v):
            do {
                return try transform(v)
            }
            catch {
                return .failure(error)
            }
        case .failure(let e):
            return .failure(e)
        case .cancelled:
            return .cancelled
        }
    }
}

extension TaskResult where T: Equatable {
    
    public func isEqual(_ rhs: TaskResult<T>) -> Bool {
        switch self {
        case .success(let v1):
            switch rhs {
            case .success(let v2):
                return v1 == v2
            case .failure:
                return false
            case .cancelled:
                return false
            }
        case .failure:
            switch rhs {
            case .success:
                return false
            case .failure:
                return true
            case .cancelled:
                return false
            }
        case .cancelled:
            switch rhs {
            case .success:
                return false
            case .failure:
                return false
            case .cancelled:
                return true
            }
        }
    }
}
