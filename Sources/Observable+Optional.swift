//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

public protocol Optionable {
    associatedtype Wrapped
    init(_ some: Wrapped)
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?
}

extension Optional: Optionable  {
    
}

extension Observable where ValueType: Optionable {
    
    public var someOnly: Observer<ValueType.Wrapped> {
        return flatMap { $0.flatMap {$0} }
    }
    
    public var noneOnly: Observer<Void> {
        return flatMap {
            $0.flatMap {_ -> Void? in nil } ?? ()
        }
    }
    
    public var isNone: Observer<Bool> {
        return map { ($0.flatMap { _ in return false }) ?? true }
    }
    
    public var isSome: Observer<Bool> {
        return map { ($0.flatMap { _ in return true }) ?? false }
    }
}

extension Observable where ValueType: Sequence, ValueType.Iterator.Element: Optionable  {
    public var anySome: Observer<ValueType.Iterator.Element.Wrapped> {
        return flatMap { res in
            for r in res {
                if let d = (r.flatMap { $0 }) {
                    return d
                }
            }
            return nil
        }
    }
}

extension Observable {
    public var optionalized: Observer<ValueType?> {
        return map { Optional.some($0) }
    }
}

