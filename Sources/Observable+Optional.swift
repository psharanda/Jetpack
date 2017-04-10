//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

public protocol Optionable {
    associatedtype Wrapped
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?
}

extension Optional: Optionable  {
    
}

extension Observable where T: Optionable {
    
    public var ignoreNil: Observable<T.Wrapped> {
        return flatMap { $0.flatMap {$0} }
    }
    
    public var nilOnly: Observable<Void> {
        return flatMap {
            $0.flatMap {_ -> Void? in nil } ?? ()
        }
    }
    
    public var isNil: Observable<Bool> {
        return map { ($0.flatMap { _ in return false }) ?? true }
    }
    
    public var isNotNil: Observable<Bool> {
        return map { ($0.flatMap { _ in return true }) ?? false }
    }
}

extension Observable where T: Sequence, T.Iterator.Element: Optionable  {
    public var any: Observable<T.Iterator.Element.Wrapped> {
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

