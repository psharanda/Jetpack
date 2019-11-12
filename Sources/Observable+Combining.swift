import Foundation

extension ObserveValueProtocol {
    
    public func combineLatest<T: ObserveValueProtocol>(_ with: T) -> Observable<(ValueType,T.ValueType)> {
        return Observable { observer in
            var left: ValueType? = nil
            var right: T.ValueType? = nil

            let lock = Lock()
            
            let disposable = with.subscribe { result in
                lock.synchronized {
                    right = result
                    if let left = left {
                        observer((left, result))
                    }
                }
            }
            
            return self.subscribe { result in
                lock.synchronized {
                    left = result
                    if let right = right {
                        observer((result,right))
                    }
                }
            }.with(disposable: disposable)
        }
    }

    
    public func combineLatest<A: ObserveValueProtocol, B: ObserveValueProtocol>(_ observable1: A, _ observable2: B) -> Observable<(ValueType, A.ValueType, B.ValueType)> {
        return combineLatest(observable1).combineLatest(observable2).map(repack)
    }
    
    public func combineLatest<A: ObserveValueProtocol, B: ObserveValueProtocol, C: ObserveValueProtocol>(_ observable1: A, _ observable2: B, _ observable3: C) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType)> {
        return combineLatest(observable1, observable2).combineLatest(observable3).map(repack)
    }
    
    public func combineLatest<A: ObserveValueProtocol, B: ObserveValueProtocol, C: ObserveValueProtocol, D: ObserveValueProtocol>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType, D.ValueType)> {
        return combineLatest(observable1, observable2, observable3).combineLatest(observable4).map(repack)
    }
    
    public func combineLatest<A: ObserveValueProtocol, B: ObserveValueProtocol, C: ObserveValueProtocol, D: ObserveValueProtocol, E: ObserveValueProtocol>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D, _ observable5: E) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType, D.ValueType, E.ValueType)> {
        return combineLatest(observable1, observable2, observable3, observable4).combineLatest(observable5).map(repack)
    }
    
    public func combineLatest<T: ObserveValueProtocol>(_ with: [T]) -> Observable<([ValueType])> where T.ValueType == ValueType {
        let initial: Observable<[ValueType]> = map { [$0] }
        let withAny = with.map { $0.asObservable }
        return withAny.reduce(initial) { left, right in
            left.combineLatest(right).map { (result, t) in
                return result + [t]
            }
        }
    }
}

extension ObserveValueProtocol {
    
    public func zip<T: ObserveValueProtocol>(_ with: T) -> Observable<(ValueType,T.ValueType)> {
        return Observable { observer in
            
            var left: ValueType? = nil
            var right: T.ValueType? = nil
            
            var leftIsNewValue = false
            var rightIsNewValue = false

            let lock = Lock()
            
            let disposable = with.subscribe { result in
                lock.synchronized {
                    right = result
                    rightIsNewValue = true
                    if let left = left, leftIsNewValue {
                        leftIsNewValue = false
                        rightIsNewValue = false
                        observer((left,result))
                    }
                }
            }
            
            return self.subscribe { result in
                lock.synchronized {
                    left = result
                    leftIsNewValue = true
                    if let right = right, rightIsNewValue {
                        leftIsNewValue = false
                        rightIsNewValue = false
                        observer((result, right))
                    }
                }                
            }.with(disposable: disposable)
        }
    }
    
    public func zip<A: ObserveValueProtocol, B: ObserveValueProtocol>(_ observable1: A, _ observable2: B) -> Observable<(ValueType, A.ValueType, B.ValueType)> {
        return zip(observable1).zip(observable2).map(repack)
    }
    
    public func zip<A: ObserveValueProtocol, B: ObserveValueProtocol, C: ObserveValueProtocol>(_ observable1: A, _ observable2: B, _ observable3: C) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType)> {
        return zip(observable1, observable2).zip(observable3).map(repack)
    }
    
    public func zip<A: ObserveValueProtocol, B: ObserveValueProtocol, C: ObserveValueProtocol, D: ObserveValueProtocol>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType, D.ValueType)> {
        return zip(observable1, observable2, observable3).zip(observable4).map(repack)
    }
    
    public func zip<A: ObserveValueProtocol, B: ObserveValueProtocol, C: ObserveValueProtocol, D: ObserveValueProtocol, E: ObserveValueProtocol>(_ observable1: A, _ observable2: B, _ observable3: C,  _ observable4: D, _ observable5: E) -> Observable<(ValueType, A.ValueType, B.ValueType, C.ValueType, D.ValueType, E.ValueType)> {
        return zip(observable1, observable2, observable3, observable4).zip(observable5).map(repack)
    }
    
    public func zip<T: ObserveValueProtocol>(_ with: [T]) -> Observable<([ValueType])> where T.ValueType == ValueType {
        let initial: Observable<[ValueType]> = map { [$0] }
        let withAny = with.map { $0.asObservable }
        return withAny.reduce(initial) { left, right in
            left.zip(right).map { (result, t) in
                return result + [t]
            }
        }
    }
}

extension ObserveValueProtocol {
    
    public func merge<T: ObserveValueProtocol>(_ observables: T...) -> Observable<ValueType> where T.ValueType == ValueType {
        return merge(observables)
    }
    
    public func merge<T: ObserveValueProtocol>(_ observables: [T]) -> Observable<ValueType> where T.ValueType == ValueType {
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
}


