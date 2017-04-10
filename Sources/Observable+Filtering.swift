//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

public extension Observable {
    
    @discardableResult
    public func filter(_ isIncluded: @escaping (T) -> Bool) -> Observable<T> {
        return flatMap {
            isIncluded($0) ? $0 : nil
        }
    }

    @discardableResult
    public func throttle(timeInterval: TimeInterval, latest: Bool = true, queue: DispatchQueue = DispatchQueue.main) -> Observable<T> {
        
        let signal = Signal<T>()
        
        var lastUpdateTime = Date.distantPast
        var lastIgnoredValue: T? = nil
        
        subscribe { result in
            let newDate = Date()
            lastIgnoredValue = result
            if newDate.timeIntervalSince(lastUpdateTime) >= timeInterval {
                lastUpdateTime = newDate
                lastIgnoredValue = nil
                signal.update(result)
                
                if latest {
                    _ = JetPackUtils.after(timeInterval, queue: queue) { [weak signal] in
                        guard let signal = signal, let lastIgnoredValue = lastIgnoredValue  else { return }
                        signal.update(lastIgnoredValue)
                    }
                }
            }
        }
        
        return signal
    }
    
    @discardableResult
    public func debounce(timeInterval: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Observable<T> {
        
        let signal = Signal<T>()
        
        var lastAfterCancel: (()->Void)? = nil
        
        subscribe { result in
            lastAfterCancel?()
            
            lastAfterCancel = JetPackUtils.after(timeInterval, queue: queue) { [weak signal] in
                guard let signal = signal  else { return }
                signal.update(result)
            }
        }
        return signal
    }
    
    @discardableResult
    public func skip(x: Int) -> Observable<T> {
        let signal = Signal<T>()
        var total = 0
        subscribe { result in
            if total >= x {
                signal.update(result)
            }
            total += 1
        }
        return signal
    }
    
    @discardableResult
    public func skip(last x: Int) -> Observable<T> {
        let signal = Signal<T>()
        var buffer: [T] = []
        subscribe { result in
            
            buffer.append(result)
            
            if buffer.count > x {
                signal.update(buffer[0])
                buffer.removeFirst()
            }            
        }
        return signal
    }
    
    @discardableResult
    public func skip<U>(until: Observable<U>) -> Observable<T> {
        let signal = Signal<T>()
        
        var canEmit = false
        
        subscribe { result in
            if canEmit {
                signal.update(result)
            }
        }
        
        until.subscribe { _ in
            canEmit = true
        }
        
        return signal
    }
    
    @discardableResult
    public func skip(while f: @escaping (T)->Bool) -> Observable<T> {
        let signal = Signal<T>()
        
        var canEmit = false
        subscribe { result in
            
            if !canEmit {
                canEmit = f(result)
            }
            
            if canEmit {
                signal.update(result)
            }
        }
        
        return signal
    }
    
    public var first: Observable<T> {
        return take(first: 1)
    }
    
    @discardableResult
    public func take(first: Int) -> Observable<T> {
        let signal = Signal<T>()
        
        var counter = 0
        
        subscribe { result in
            if counter < first {
                signal.update(result)
            }
            counter += 1
        }
        return signal
    }
    
    @discardableResult
    public func take<U>(until: Observable<U>) -> Observable<T> {
        let signal = Signal<T>()
        
        var canEmit = true
        
        subscribe { result in
            if canEmit {
                signal.update(result)
            }
        }
        
        until.subscribe { _ in
            canEmit = false
        }
        
        return signal
    }
    
    @discardableResult
    public func take(while f: @escaping (T)->Bool) -> Observable<T> {
        let signal = Signal<T>()
        
        var canEmit = true
        subscribe { result in
            
            if canEmit {
                canEmit = f(result)
            }
            
            if canEmit {
                signal.update(result)
            }
        }
        
        return signal
    }
    
    @discardableResult
    public func find(_ f: @escaping (T) -> Bool) -> Observable<T> {
        let signal = Signal<T>()
        var found = false
        subscribe { result in
            if f(result) && !found {
                found = true
                signal.update(result)
            }
        }
        return signal
    }
    
    @discardableResult
    public func element(at index: Int) -> Observable<T> {
        let signal = Signal<T>()
        var currentIndex = 0
        subscribe { result in
            if currentIndex == index {
                signal.update(result)
            }
            currentIndex += 1
        }
        return signal
    }
    
    @discardableResult
    public func pausable(_ controller: Observable<Bool>) -> Observable<T> {
        let signal = Signal<T>()
        
        subscribe {[weak controller] a in
            if let canUpdate = controller?.lastValue, canUpdate {
                signal.update(a)
            }
        }
        
        return signal
    }
    
    @discardableResult
    public func pausableBuffered(_ controller: Observable<Bool>) -> Observable<T> {
        let signal = Signal<T>()
        
        var buffer: [T] = []
        
        subscribe {[weak controller] a in
            if let canUpdate = controller?.lastValue, canUpdate {
                buffer.forEach {signal.update($0)}
                buffer.removeAll()
                signal.update(a)
            } else {
                buffer.append(a)
            }
        }
        
        return signal
    }
}

public extension Observable where T: Equatable {
    
    public var distinct: Observable<T> {
        let signal = Signal<T>()
        
        subscribe { result in
            if signal.lastValue != result {
                signal.update(result)
            }
        }
        return signal
    }
    
    @discardableResult
    public func equal(_ value: T) -> Observable<T> {
        return filter {
            ($0 == value)
        }
    }
    
    @discardableResult
    public func contains(where f: @escaping (T)->Bool) -> Observable<Bool> {
        let signal = Signal<Bool>()
        
        var val = false
        
        subscribe { result in
            if !val && f(result) {
                val = true
                signal.update(val)
            }
        }
        return signal
    }
    
    @discardableResult
    public func contains(_ value: T) -> Observable<Bool> {
        return contains { value == $0 }
    }
}

public extension Observable where T: Hashable {
    
    public var unique: Observable<T> {
        let signal = Signal<T>()
        
        var set = Set<T>()
        
        subscribe { result in
            if !set.contains(result) {
                signal.update(result)
                set.insert(result)
            }
        }
        return signal
    }
}
