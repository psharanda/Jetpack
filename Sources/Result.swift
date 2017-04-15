//
//  Created by Pavel Sharanda on 12.04.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

public protocol ResultConvertible {
    associatedtype ValueType
    var result: Result<ValueType> {get}
}

extension ResultConvertible {
    public var value: ValueType? {
        switch result {
        case .success(let v):
            return v
        case .failure:
            return nil
        }
    }
    
    public var error: Error? {
        switch result {
        case .success:
            return nil
        case .failure(let e):
            return e
        }
    }
}


public enum Result<T>: ResultConvertible {
    public typealias ValueType = T
    
    case success(T) //contains value
    case failure(Error) //contains error
    
    public init(value: T) {
        self = .success(value)
    }
    
    public init(error: Error) {
        self = .failure(error)
    }
    
    public var result: Result<T> {
        return self
    }
}



extension Result {
    public func map<U>(_ transform: (T) throws -> U) rethrows -> Result<U> {
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
        }
    }
    
    public func flatMap<U>(_ transform: (T) throws -> Result<U>) rethrows -> Result<U> {
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
        }
    }
}

extension Result where T: Equatable {
    
    public func isEqual(_ rhs: Result<T>) -> Bool {
        switch self {
        case .success(let v1):
            switch rhs {
            case .success(let v2):
                return v1 == v2
            case .failure:
                return false
            }
        case .failure(let e1):
            switch rhs {
            case .success:
                return false
            case .failure(let e2):
                return e1.localizedDescription == e2.localizedDescription
            }
        }
    }
}
