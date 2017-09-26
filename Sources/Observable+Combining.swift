import Foundation



public extension ObservableProtocol {
    
    public func combine<T: ObservableProtocol>(_ with: T) -> Observable<(ValueType?,T.ValueType?)> {
        return Observable { observer in
            
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
    
    public func combine<A: ObservableProtocol, B: ObservableProtocol>(_ observable1: A, _ observable2: B) -> Observable<(ValueType?, A.ValueType?, B.ValueType?)> {
        return combine(observable1).combine(observable2).map(repack)
    }
    
    public func combine<A: ObservableProtocol, B: ObservableProtocol, C: ObservableProtocol>(_ observable1: A, _ observable2: B, _ observable3: C) -> Observable<(ValueType?, A.ValueType?, B.ValueType?, C.ValueType?)> {
        return combine(observable1, observable2).combine(observable3).map(repack)
    }
    
    public func combine<A: ObservableProtocol, B: ObservableProtocol, C: ObservableProtocol, D: ObservableProtocol>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D) -> Observable<(ValueType?, A.ValueType?, B.ValueType?, C.ValueType?, D.ValueType?)> {
        return combine(observable1, observable2, observable3).combine(observable4).map(repack)
    }

    public func combine<T: ObservableProtocol>(_ with: [T]) -> Observable<([ValueType?])> where T.ValueType == ValueType {
        let initial: Observable<[ValueType?]> = map { [$0] }
        let withAny = with.map { $0.asObservable }
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

public extension ObservableProtocol {
    
    public func combineLatest<T: ObservableProtocol>(_ with: T) -> Observable<(ValueType,T.ValueType)> {
        return Observable { observer in
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

    
    public func combineLatest<A: ObservableProtocol, B: ObservableProtocol>(_ observable1: A, _ observable2: B) -> Observable<(ValueType, A.ValueType, B.ValueType)> {
        return combineLatest(observable1).combineLatest(observable2).map(repack)
    }
    
    public func combineLatest<A: ObservableProtocol, B: ObservableProtocol, C: ObservableProtocol>(_ observable1: A, _ observable2: B, _ observable3: C) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType)> {
        return combineLatest(observable1, observable2).combineLatest(observable3).map(repack)
    }
    
    public func combineLatest<A: ObservableProtocol, B: ObservableProtocol, C: ObservableProtocol, D: ObservableProtocol>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType, D.ValueType)> {
        return combineLatest(observable1, observable2, observable3).combineLatest(observable4).map(repack)
    }
    
    public func combineLatest<T: ObservableProtocol>(_ with: [T]) -> Observable<([ValueType])> where T.ValueType == ValueType {
        let initial: Observable<[ValueType]> = map { [$0] }
        let withAny = with.map { $0.asObservable }
        return withAny.reduce(initial) { left, right in
            left.combineLatest(right).map { (result, t) in
                return result + [t]
            }
        }
    }
}

public extension ObservableProtocol {
    
    public func zip<T: ObservableProtocol>(_ with: T) -> Observable<(ValueType,T.ValueType)> {
        return Observable { observer in
            
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
    
    public func zip<A: ObservableProtocol, B: ObservableProtocol>(_ observable1: A, _ observable2: B) -> Observable<(ValueType, A.ValueType, B.ValueType)> {
        return zip(observable1).zip(observable2).map(repack)
    }
    
    public func zip<A: ObservableProtocol, B: ObservableProtocol, C: ObservableProtocol>(_ observable1: A, _ observable2: B, _ observable3: C) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType)> {
        return zip(observable1, observable2).zip(observable3).map(repack)
    }
    
    public func zip<A: ObservableProtocol, B: ObservableProtocol, C: ObservableProtocol, D: ObservableProtocol>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType, D.ValueType)> {
        return zip(observable1, observable2, observable3).zip(observable4).map(repack)
    }
    
    public func zip<T: ObservableProtocol>(_ with: [T]) -> Observable<([ValueType])> where T.ValueType == ValueType {
        let initial: Observable<[ValueType]> = map { [$0] }
        let withAny = with.map { $0.asObservable }
        return withAny.reduce(initial) { left, right in
            left.zip(right).map { (result, t) in
                return result + [t]
            }
        }
    }
}

public extension ObservableProtocol {
    
    public func merge<T: ObservableProtocol>(_ observables: T...) -> Observable<ValueType> where T.ValueType == ValueType {
        return merge(observables)
    }
    
    public func merge<T: ObservableProtocol>(_ observables: [T]) -> Observable<ValueType> where T.ValueType == ValueType {
        return Observable { observer in
    
            let disposable = observables.reduce(EmptyDisposable() as Disposable) {
                return $0.with(disposable: $1.subscribe { result in
                    observer(result)
                })
            }
            
            return self.subscribe { result in
                observer(result)
            }.with(disposable: disposable)
        }
    }

    
    public func sample<T: ObservableProtocol>(_ with: T) -> Observable<ValueType> {
        return Observable { observer in
            
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

    public func withLatestFrom<T: ObservableProtocol>(_ with: T) -> Observable<(ValueType,T.ValueType)> {
        return Observable { observer in
            var lastValue: T.ValueType?
            
            let disposable = with.subscribe { result in
                lastValue = result
            }
            
            return self.subscribe { result in
                if let lastValue = lastValue {
                    observer((result, lastValue))
                }
            }.with(disposable: disposable)
        }
    }
    
    public func amb<T: ObservableProtocol>(_ observables: T...) -> Observable<ValueType> where T.ValueType == ValueType {
        return amb(observables)
    }
    
    //emit events only from observable which emitted the very first event
    public func amb<T: ObservableProtocol>(_ observables: [T]) -> Observable<ValueType> where T.ValueType == ValueType {
        return Observable { observer in
            var config = (0..<(observables.count + 1)).map { _ in  false }
            let all = [self.asObservable] + observables.map { $0.asObservable }
            var c = 0
            
            return all.reduce(EmptyDisposable() as Disposable) {
                c += 1
                let idx = c - 1
                return $0.with(disposable: $1.subscribe { result in
                    
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
