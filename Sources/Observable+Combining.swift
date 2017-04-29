import Foundation



public extension Observable {
    
    public func combine<T: Observable>(_ with: T) -> Observer<(ValueType?,T.ValueType?)> {
        return Observer { observer in
            
            var left: ValueType?
            var right: T.ValueType?
            
            let disposable = with.subscribe { result in
                right = result
                observer((left,right))
            }
            
            return self.subscribe { result in
                left = result
                observer((left,right))
            }.with(disposable: disposable)
        }
    }
    
    public func combine<A: Observable, B: Observable>(_ observable1: A, _ observable2: B) -> Observer<(ValueType?, A.ValueType?, B.ValueType?)> {
        return combine(observable1).combine(observable2).map(repack)
    }
    
    public func combine<A: Observable, B: Observable, C: Observable>(_ observable1: A, _ observable2: B, _ observable3: C) -> Observer<(ValueType?, A.ValueType?, B.ValueType?, C.ValueType?)> {
        return combine(observable1, observable2).combine(observable3).map(repack)
    }
    
    public func combine<A: Observable, B: Observable, C: Observable, D: Observable>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D) -> Observer<(ValueType?, A.ValueType?, B.ValueType?, C.ValueType?, D.ValueType?)> {
        return combine(observable1, observable2, observable3).combine(observable4).map(repack)
    }

    public func combine<T: Observable>(_ with: [T]) -> Observer<([ValueType?])> where T.ValueType == ValueType {
        let initial: Observer<[ValueType?]> = map { [$0] }
        let withAny = with.map { $0.asObserver }
        return withAny.reduce(initial) { left, right in
            left.combine(right).map { (result, t) in
                if let result = result {
                    return result + [t]
                } else {
                    return [nil] + [t]
                }
            }
        }
    }
}

public extension Observable {
    
    public func combineLatest<T: Observable>(_ with: T) -> Observer<(ValueType,T.ValueType)> {
        return Observer { observer in
            var left: ValueType?
            var right: T.ValueType?
            
            let disposable = with.subscribe { result in
                right = result
                if let left = left, let right = right {
                    observer((left,right))
                }
            }
            
            return self.subscribe { result in
                left = result
                if let left = left, let right = right {
                    observer((left,right))
                }
            }.with(disposable: disposable)
        }
    }

    
    public func combineLatest<A: Observable, B: Observable>(_ observable1: A, _ observable2: B) -> Observer<(ValueType, A.ValueType, B.ValueType)> {
        return combineLatest(observable1).combineLatest(observable2).map(repack)
    }
    
    public func combineLatest<A: Observable, B: Observable, C: Observable>(_ observable1: A, _ observable2: B, _ observable3: C) -> Observer<(ValueType, A.ValueType, B.ValueType, C.ValueType)> {
        return combineLatest(observable1, observable2).combineLatest(observable3).map(repack)
    }
    
    public func combineLatest<A: Observable, B: Observable, C: Observable, D: Observable>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D) -> Observer<(ValueType, A.ValueType, B.ValueType, C.ValueType, D.ValueType)> {
        return combineLatest(observable1, observable2, observable3).combineLatest(observable4).map(repack)
    }
    
    public func combineLatest<T: Observable>(_ with: [T]) -> Observer<([ValueType])> where T.ValueType == ValueType {
        let initial: Observer<[ValueType]> = map { [$0] }
        let withAny = with.map { $0.asObserver }
        return withAny.reduce(initial) { left, right in
            left.combineLatest(right).map { (result, t) in
                return result + [t]
            }
        }
    }
}

public extension Observable {
    
    public func zip<T: Observable>(_ with: T) -> Observer<(ValueType,T.ValueType)> {
        return Observer { observer in
            
            var left: ValueType?
            var right: T.ValueType?
            
            var leftIsNewValue = false
            var rightIsNewValue = false
            
            let disposable = with.subscribe { result in
                right = result
                rightIsNewValue = true
                if let left = left, let right = right, leftIsNewValue {
                    leftIsNewValue = false
                    rightIsNewValue = false
                    observer((left,right))
                }
            }
            
            return self.subscribe { result in
                left = result
                leftIsNewValue = true
                if let left = left, let right = right, rightIsNewValue {
                    leftIsNewValue = false
                    rightIsNewValue = false
                    observer((left,right))
                }
            }.with(disposable: disposable)
        }
    }
    
    public func zip<A: Observable, B: Observable>(_ observable1: A, _ observable2: B) -> Observer<(ValueType, A.ValueType, B.ValueType)> {
        return zip(observable1).zip(observable2).map(repack)
    }
    
    public func zip<A: Observable, B: Observable, C: Observable>(_ observable1: A, _ observable2: B, _ observable3: C) -> Observer<(ValueType, A.ValueType, B.ValueType, C.ValueType)> {
        return zip(observable1, observable2).zip(observable3).map(repack)
    }
    
    public func zip<A: Observable, B: Observable, C: Observable, D: Observable>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D) -> Observer<(ValueType, A.ValueType, B.ValueType, C.ValueType, D.ValueType)> {
        return zip(observable1, observable2, observable3).zip(observable4).map(repack)
    }
    
    public func zip<T: Observable>(_ with: [T]) -> Observer<([ValueType])> where T.ValueType == ValueType {
        let initial: Observer<[ValueType]> = map { [$0] }
        let withAny = with.map { $0.asObserver }
        return withAny.reduce(initial) { left, right in
            left.zip(right).map { (result, t) in
                return result + [t]
            }
        }
    }
}

public extension Observable {
    
    public func merge<T: Observable>(_ observables: T...) -> Observer<ValueType> where T.ValueType == ValueType {
        return merge(observables)
    }
    
    public func merge<T: Observable>(_ observables: [T]) -> Observer<ValueType> where T.ValueType == ValueType {
        return Observer { observer in
    
            let disposable = observables.reduce(EmptyDisposable() as Disposable) {
                return $0.0.with(disposable: $0.1.subscribe { result in
                    observer(result)
                })
            }
            
            return self.subscribe { result in
                observer(result)
            }.with(disposable: disposable)
        }
    }

    
    public func sample<T: Observable>(_ with: T) -> Observer<ValueType> {
        return Observer { observer in
            
            var value: ValueType?
            
            let disposable = with.subscribe { _ in
                if let v = value {
                    observer(v)
                    value = nil
                }
            }
            
            return self.subscribe { result in
                value = result
            }.with(disposable: disposable)
        }
    }

    public func withLatestFrom<T: Observable>(_ with: T) -> Observer<(ValueType,T.ValueType)> {
        return Observer { observer in
            var lastValue: T.ValueType?
            
            let disposable = with.subscribe { result in
                lastValue = result
            }
            
            return self.subscribe { result in
                if let lastValue = lastValue {
                    observer(result, lastValue)
                }
            }.with(disposable: disposable)
        }
    }
    
    public func amb<T: Observable>(_ observables: T...) -> Observer<ValueType> where T.ValueType == ValueType {
        return amb(observables)
    }
    
    //emit events only from observable which emitted the very first event
    public func amb<T: Observable>(_ observables: [T]) -> Observer<ValueType> where T.ValueType == ValueType {
        return Observer { observer in
            var config = (0..<(observables.count + 1)).map { _ in  false }
            let all = [self.asObserver] + observables.map { $0.asObserver }
            var c = 0
            
            return all.reduce(EmptyDisposable() as Disposable) {
                c += 1
                let idx = c - 1
                return $0.0.with(disposable: $0.1.subscribe { result in
                    
                    if !(config.reduce(false) { $0 || $1 }) {
                        config[idx] = true
                    }
                    
                    if config[idx] {
                        observer(result)
                    }
                })
            }
        }
    }
}
