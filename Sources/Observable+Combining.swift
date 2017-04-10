//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation


private struct WeakBox<T: AnyObject> {
    weak var object: T? = nil
}

public extension Observable {
    
    @discardableResult
    public func combine(_ with: Observable<T>...) -> Observable<([T?])> {
        return combine(with)
    }
    
    @discardableResult
    public func combine(_ with: [Observable<T>]) -> Observable<([T?])> {
        
        let signal = Signal<[T?]>()
        
        
        let weakWith = with.map {WeakBox(object: $0)}
        
        subscribe { a in
            var values = weakWith.map { $0.object?.lastValue }
            values.insert(a, at: 0)
            signal.update(values)
        }
        
        for (idx, obj) in with.enumerated() {
            var mutWith = with
            mutWith.remove(at: idx)
            mutWith.insert(self, at: 0)
            
            let weakMutWith = mutWith.map { WeakBox(object: $0) }
            
            obj.subscribe { a in
                let values = weakMutWith.map { $0.object?.lastValue }
                var mutValues = values
                mutValues.insert(a, at: idx + 1)
                signal.update(mutValues)
            }
        }
        return signal
    }
    
    @discardableResult
    public func combine<U>(_ with: Observable<U>) -> Observable<(T?,U?)> {
        let signal = Signal<(T?, U?)>()
        
        subscribe {[weak with] a in
            signal.update((a,with?.lastValue))
            
        }
        with.subscribe {[weak self] b in
            signal.update((self?.lastValue,b))
        }
        return signal
    }
    
    @discardableResult
    public func combine<A, B>(_ observable1: Observable<A>, _ observable2: Observable<B>) -> Observable<(T?, A?, B?)> {
        let signal = Signal<(T?, A?, B?)>()
        
        subscribe {[weak observable1, weak observable2] result in
            signal.update((result, observable1?.lastValue, observable2?.lastValue))
        }
        
        observable1.subscribe {[weak self, weak observable2] result in
            signal.update((self?.lastValue, result, observable2?.lastValue))
        }
        
        observable2.subscribe {[weak self, weak observable1] result in
            signal.update((self?.lastValue, observable1?.lastValue, result))
        }
        return signal
    }
    
    @discardableResult
    public func combine<A, B, C>(_ observable1: Observable<A>, _ observable2: Observable<B>, _ observable3: Observable<C>) -> Observable<(T?, A?, B?, C?)> {
        let signal = Signal<(T?, A?, B?, C?)>()
        
        subscribe {[weak observable1, weak observable2, weak observable3] result in
            signal.update((result, observable1?.lastValue, observable2?.lastValue, observable3?.lastValue))
        }
        observable1.subscribe {[weak self, weak observable2, weak observable3] result in
            signal.update((self?.lastValue, result, observable2?.lastValue, observable3?.lastValue))
        }
        
        observable2.subscribe {[weak self, weak observable1, weak observable3] result in
            signal.update((self?.lastValue, observable1?.lastValue, result, observable3?.lastValue))
        }
        
        observable3.subscribe {[weak self, weak observable1, weak observable2] result in
            signal.update((self?.lastValue, observable1?.lastValue, observable2?.lastValue, result))
        }
        return signal
    }
    
    @discardableResult
    public func combine<A, B, C, D>(_ observable1: Observable<A>, _ observable2: Observable<B>, _ observable3: Observable<C>, _ observable4: Observable<D>) -> Observable<(T?, A?, B?, C?, D?)> {
        let signal = Signal<(T?, A?, B?, C?, D?)>()
        
        subscribe {[weak observable1, weak observable2, weak observable3, weak observable4] result in
            signal.update((result, observable1?.lastValue, observable2?.lastValue, observable3?.lastValue, observable4?.lastValue))
            
        }
        observable1.subscribe {[weak self, weak observable2, weak observable3, weak observable4] result in
            signal.update((self?.lastValue, result, observable2?.lastValue, observable3?.lastValue, observable4?.lastValue))
        }
        
        observable2.subscribe {[weak self, weak observable1, weak observable3, weak observable4] result in
            signal.update((self?.lastValue, observable1?.lastValue, result, observable3?.lastValue, observable4?.lastValue))
        }
        
        observable3.subscribe {[weak self, weak observable1, weak observable2, weak observable4] result in
            signal.update((self?.lastValue, observable1?.lastValue, observable2?.lastValue, result, observable4?.lastValue))
        }
        
        observable4.subscribe {[weak self, weak observable1, weak observable2, weak observable3] result in
            signal.update((self?.lastValue, observable1?.lastValue, observable2?.lastValue, observable3?.lastValue, result))
        }
        
        return signal
    }
}

public extension Observable {

    @discardableResult
    public func combineLatest(_ with: Observable<T>...) -> Observable<([T])> {
        return combineLatest(with)
    }
    
    @discardableResult
    public func combineLatest(_ with: [Observable<T>]) -> Observable<([T])> {
        
        let signal = Signal<[T]>()
        
        let weakWith = with.map {WeakBox(object: $0)}
        
        subscribe { a in
            
            var values = weakWith.flatMap { $0.object?.lastValue }
            if values.count == with.count {
                values.insert(a, at: 0)
                signal.update(values)
            }
        }
        
        for (idx, obj) in with.enumerated() {
            var mutWith = with
            mutWith.remove(at: idx)
            mutWith.insert(self, at: 0)
            
            let weakMutWith = mutWith.map { WeakBox(object: $0) }
            
            obj.subscribe { a in
                let values = weakMutWith.flatMap { $0.object?.lastValue }
                if values.count == with.count {
                    var mutValues = values
                    mutValues.insert(a, at: idx + 1)
                    signal.update(mutValues)
                }
            }
        }
        return signal
    }
    
    @discardableResult
    public func combineLatest<U>(_ with: Observable<U>) -> Observable<(T,U)> {
        let signal = Signal<(T, U)>()
        
        subscribe {[weak with] a in
            if let withValue = with?.lastValue {
                signal.update((a,withValue))
            }
            
        }
        with.subscribe {[weak self] b in
            if let value = self?.lastValue {
                signal.update((value,b))
            }
        }
        return signal
    }
    
    @discardableResult
    public func combineLatest<A, B>(_ observable1: Observable<A>, _ observable2: Observable<B>) -> Observable<(T, A, B)> {
        return combineLatest(observable1).combineLatest(observable2).map(repack)
    }
    
    @discardableResult
    public func combineLatest<A, B, C>(_ observable1: Observable<A>, _ observable2: Observable<B>, _ observable3: Observable<C>) -> Observable<(T, A, B, C)> {
        return combineLatest(observable1, observable2).combineLatest(observable3).map(repack)
    }
    
    @discardableResult
    public func combineLatest<A, B, C, D>(_ observable1: Observable<A>, _ observable2: Observable<B>, _ observable3: Observable<C>, observable4: Observable<D>) -> Observable<(T, A, B, C, D)> {
        return combineLatest(observable1, observable2, observable3).combineLatest(observable4).map(repack)
    }
}

public extension Observable {
    
    @discardableResult
    public func zip<U>(_ with: Observable<U>) -> Observable<(T,U)> {
        let signal = Signal<(T, U)>()
        
        var aIsNewValue = false
        var bIsNewValue = false
        
        subscribe {[weak with] a in
            aIsNewValue = true
            
            if let withValue = with?.lastValue, bIsNewValue {
                aIsNewValue = false
                bIsNewValue = false
                signal.update((a,withValue))
            }
            
        }
        with.subscribe {[weak self] b in
            bIsNewValue = true
            if let value = self?.lastValue, aIsNewValue {
                aIsNewValue = false
                bIsNewValue = false
                signal.update((value,b))
            }
        }
        return signal
    }
    
    @discardableResult
    public func zip<A, B>(_ observable1: Observable<A>, _ observable2: Observable<B>) -> Observable<(T, A, B)> {
        return zip(observable1).zip(observable2).map(repack)
    }
    
    @discardableResult
    public func zip<A, B, C>(_ observable1: Observable<A>, _ observable2: Observable<B>, _ observable3: Observable<C>) -> Observable<(T, A, B, C)> {
        return zip(observable1, observable2).zip(observable3).map(repack)
    }
    
    @discardableResult
    public func zip<A, B, C, D>(_ observable1: Observable<A>, _ observable2: Observable<B>, _ observable3: Observable<C>, observable4: Observable<D>) -> Observable<(T, A, B, C, D)> {
        return zip(observable1, observable2, observable3).zip(observable4).map(repack)
    }
}

public extension Observable {
    
    @discardableResult
    public func merge(_ observables: Observable<T>...) -> Observable<T> {
        return merge(observables)
    }
    
    @discardableResult
    public func merge(_ observables: [Observable<T>]) -> Observable<T> {
        let signal = Signal<T>()
        subscribe { result in
            signal.update(result)
        }
        
        observables.forEach {
            $0.subscribe { result in
                signal.update(result)
            }
        }
        
        return signal
    }

    @discardableResult
    public func sample<U>(_ with: Observable<U>) -> Observable<(T)> {
        let signal = Signal<(T)>()
        
        var value: T? = nil
        subscribe { a in
            value = a
        }
        
        with.subscribe { b in
            
            if let v = value {
                signal.update(v)
                value = nil
            }
        }
        return signal
    }
    
    @discardableResult
    public func withLatestFrom<U>(_ with: Observable<U>) -> Observable<(T,U)> {
        let signal = Signal<(T, U)>()
        
        subscribe {[weak with] a in
            if let withValue = with?.lastValue {
                signal.update((a,withValue))
            }
        }
        
        return signal
    }
    
    @discardableResult
    public func amb(_ observables: Observable<T>...) -> Observable<T> {
        return amb(observables)
    }
    
    @discardableResult
    public func amb(_ observables: [Observable<T>]) -> Observable<T> {
        let signal = Signal<T>()
        
        let all: [Observable<T>] = [self] + observables
        
        var config: [Bool] = all.map { _ in false }
        
        for (idx, observable) in all.enumerated() {
            observable.subscribe { result in
                
                if !(config.reduce(false) { $0 || $1 }) {
                    config[idx] = true
                }
                
                if config[idx] {
                    signal.update(result)
                }
            }
        }
        
        return signal
    }
}
