//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension ObserveValueProtocol {
    
    public func map<U>(_ transform: @escaping (ValueType) -> U) -> Observable<U> {
        return Observable { observer in
            return self.subscribe { result in
                observer(transform(result))
            }
        }
    }
    
    public func map<U>(keyPath: KeyPath<ValueType, U>) -> Observable<U> {
        return map { $0[keyPath: keyPath] }
    }
    
    public func compactMap<U>(_ transform: @escaping (ValueType) -> U?) -> Observable<U> {
        return Observable { observer in
            return self.subscribe { result in
                if let newResult = transform(result) {
                    observer(newResult)
                }
            }
        }
    }
    
    public func filter(_ isIncluded: @escaping (ValueType) -> Bool) -> Observable<ValueType> {
        return compactMap { result in
            return isIncluded(result) ? result : nil
        }
    }
    
    public func forEach(_ f: @escaping (ValueType) -> Void) -> Observable<ValueType> {
        return Observable { observer in
            return self.subscribe { result in
                f(result)
                observer(result)
            }
        }
    }
    
    public func distinctUntilChanged(_ isEqual: @escaping (ValueType, ValueType) -> Bool) -> Observable<ValueType> {
        return Observable { observer in
            var lastValue: ValueType?

            return self.subscribe { result in
                if (lastValue.map { !isEqual($0, result) }) ?? true {
                    lastValue = result
                    observer(result)
                }
            }
        }
    }
}

extension ObserveValueProtocol {
    
    public var withOldValue: Observable<(new: ValueType, old: ValueType?)> {
        return Observable { observer in
            var prevValue: ValueType?
            return self.subscribe { result in
                let oldPrevValue = prevValue
                prevValue = result
                observer((result, oldPrevValue))
            }
        }
    }
}

extension ObserveValueProtocol {
    
    public func just<U>(_ value: U) -> Observable<U> {
        return map { _ -> U in
            return value
        }
    }
    
    public var just: Observable<Void> {
        return just(())
    }
}

extension ObserveValueProtocol where ValueType: Equatable {
    
    public var distinctUntilChanged: Observable<ValueType> {
        return distinctUntilChanged { $0 == $1 }
    }
}

extension ObserveValueProtocol {

    public var first: Observable<ValueType> {
        return take(first: 1)
    }
    
    public func take(first: Int) -> Observable<ValueType> {
        return Observable { observer in
            var counter = 0
            
            var disposable: Disposable?
            disposable = self.subscribe { result in
                if counter < first {
                    counter += 1
                    observer(result)
                } else {
                    disposable?.dispose()
                    disposable = nil
                }
            }
            return disposable!
        }
    }

    public func take(while f: @escaping (ValueType) -> Bool) -> Observable<ValueType> {
        return Observable { observer in
            var canEmit = true
            var disposable: Disposable?
            disposable = self.subscribe { result in
  
                if canEmit {
                    canEmit = f(result)
                }
                
                if canEmit {
                    observer(result)
                } else {
                    disposable?.dispose()
                    disposable = nil
                }
            }
            return disposable!
        }
    }
}

