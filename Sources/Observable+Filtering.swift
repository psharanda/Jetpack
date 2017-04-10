//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension Observable {
    
    public func filter(_ isIncluded: @escaping (ValueType) -> Bool) -> Observer<ValueType> {
        return flatMap {
            isIncluded($0) ? $0 : nil
        }
    }
    
    public func forEach(_ f: @escaping (ValueType) -> Void) -> Observer<ValueType> {
        return Observer { observer in
            return self.subscribe { result in
                f(result)
                observer(result)
            }
        }
    }

    public func throttle(timeInterval: TimeInterval, latest: Bool = true, queue: DispatchQueue = DispatchQueue.main) -> Observer<ValueType> {
        var lastUpdateTime = Date.distantPast
        var lastIgnoredValue: ValueType? = nil
        
        var lastAfterCancel: (()->Void)? = nil
        
        return Observer { observer in
            return self.subscribe { result in
                let newDate = Date()
                lastIgnoredValue = result
                if newDate.timeIntervalSince(lastUpdateTime) >= timeInterval {
                    lastUpdateTime = newDate
                    lastIgnoredValue = nil
                    observer(result)
                    
                    if latest {
                        lastAfterCancel = JetPackUtils.after(timeInterval, queue: queue) {
                            guard let lastIgnoredValue = lastIgnoredValue  else { return }
                            observer(lastIgnoredValue)
                        }
                    }
                }
            }.with(disposable: DelegateDisposable {
                lastAfterCancel?()
                lastAfterCancel = nil
            })
        }
    }

    public func debounce(timeInterval: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Observer<ValueType> {                
        var lastAfterCancel: (()->Void)? = nil
        
        return Observer { observer in
            return self.subscribe { result in
                lastAfterCancel?()
                
                lastAfterCancel = JetPackUtils.after(timeInterval, queue: queue) {
                    observer(result)
                }
            }.with(disposable: DelegateDisposable {
                lastAfterCancel?()
                lastAfterCancel = nil
            })
        }
    }

    
    public func skip(x: Int) -> Observer<ValueType> {
        var total = 0
        return Observer { observer in
            return self.subscribe { result in
                if total >= x {
                    observer(result)
                }
                total += 1
            }
        }
    }
    
    public func skip(last x: Int) -> Observer<ValueType> {
        var buffer: [ValueType] = []
        return Observer { observer in
            return self.subscribe { result in
                buffer.append(result)
                
                if buffer.count > x {
                    observer(buffer[0])
                    buffer.removeFirst()
                }
            }
        }
    }
    
    public func skip<U: Observable>(until: U) -> Observer<ValueType> {
        var canEmit = false
        
        let disposable = until.subscribe { _ in
            canEmit = true
        }
        
        return Observer { observer in
            return self.subscribe { result in
                if canEmit {
                    observer(result)
                }
            }.with(disposable: disposable)
        }
    }

    public func skip(while f: @escaping (ValueType)->Bool) -> Observer<ValueType> {
        var canEmit = false
        
        return Observer { observer in
            return self.subscribe { result in
                if !canEmit {
                    canEmit = f(result)
                }
                
                if canEmit {
                    observer(result)
                }
            }
        }
    }

    public var first: Observer<ValueType> {
        return take(first: 1)
    }
    
    public func take(first: Int) -> Observer<ValueType> {
        var counter = 0
        
        return Observer { observer in
            return self.subscribe { result in
                if counter < first {
                    observer(result)
                }
                counter += 1
            }
        }
    }
    
    public func take<U: Observable>(until: U) -> Observer<ValueType> {
        var canEmit = true
        
        let disposable = until.subscribe { _ in
            canEmit = false
        }
        
        return Observer { observer in
            return self.subscribe { result in
                if canEmit {
                    observer(result)
                }
            }.with(disposable: disposable)
        }
    }

    public func take(while f: @escaping (ValueType)->Bool) -> Observer<ValueType> {
        var canEmit = true
        
        return Observer { observer in
            return self.subscribe { result in
                if !canEmit {
                    canEmit = f(result)
                }
                
                if canEmit {
                    observer(result)
                }
            }
        }
    }
    
    public func find(_ f: @escaping (ValueType) -> Bool) -> Observer<ValueType> {
        var found = false

        return Observer { observer in
            return self.subscribe { result in
                if f(result) && !found {
                    found = true
                    observer(result)
                }
            }
        }
    }

    public func element(at index: Int) -> Observer<ValueType> {
        var currentIndex = 0
        return Observer { observer in
            return self.subscribe { result in
                if currentIndex == index {
                    observer(result)
                }
                currentIndex += 1
            }
        }
    }
    
    public func pausable<U: Observable>(_ controller: U) -> Observer<ValueType> where U.ValueType == Bool {
        var canEmit = false
        
        let disposable = controller.subscribe { result in
            canEmit = result
        }
        
        return Observer { observer in
            return self.subscribe { result in
                if canEmit {
                    observer(result)
                }
            }.with(disposable: disposable)
        }
    }

    public func pausableBuffered<U: Observable>(_ controller: U) -> Observer<ValueType> where U.ValueType == Bool {
        var canEmit = false
        var buffer: [ValueType] = []
        
        let disposable = controller.subscribe { result in
            canEmit = result
        }
        
        return Observer { observer in
            return self.subscribe { result in
                if canEmit {
                    buffer.forEach {observer($0)}
                    buffer.removeAll()
                    observer(result)
                } else {
                    buffer.append(result)
                }

            }.with(disposable: disposable)
        }
    }
}

public extension Observable where ValueType: Equatable {
    
    public var distinct: Observer<ValueType> {
        var lastValue: ValueType?
        
        return flatMap { result in
            if let lv = lastValue {
                return (lv != result) ? lv : nil
            } else {
                lastValue = result
                return result
            }
        }
    }
    
    public func equal(_ value: ValueType) -> Observer<ValueType> {
        return filter {
            ($0 == value)
        }
    }
    
    public func contains(where f: @escaping (ValueType)->Bool) -> Observer<Bool> {
        var val = false
        
        return Observer<Bool> { observer in
            return self.subscribe { result in
                if !val && f(result) {
                    val = true
                    observer(val)
                }
            }
        }
    }
    
    public func contains(_ value: ValueType) -> Observer<Bool> {
        return contains { value == $0 }
    }
    
    public func findIndex(of value: ValueType) -> Observer<Int> {
        var idx = 0
        
        return Observer<Int> { observer in
            return self.subscribe { result in
                if  result == value {
                    observer(idx)
                }
                idx += 1
            }
        }
    }
}

extension Observable where ValueType: Hashable {
    
    public var unique: Observer<ValueType> {
        var set = Set<ValueType>()
        
        return Observer { observer in
            return self.subscribe { result in
                if !set.contains(result) {
                    observer(result)
                    set.insert(result)
                }
            }
        }
    }
}

extension Observable {
    
    public func findIndex(_ f: @escaping ((ValueType) -> Bool)) -> Observer<Int> {
        var idx = 0
        
        return Observer { observer in
            return self.subscribe { result in
                if  f(result) {
                    observer(idx)
                }
                idx += 1
            }
        }
    }
}
