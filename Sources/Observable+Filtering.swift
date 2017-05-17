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
        return Observer { observer in
            
            var lastUpdateTime = Date.distantPast
            var lastIgnoredValue: ValueType? = nil
            var lastAfterCancel: Disposable? = nil
            
            return self.subscribe { result in
                let newDate = Date()
                lastIgnoredValue = result
                if newDate.timeIntervalSince(lastUpdateTime) >= timeInterval {
                    lastUpdateTime = newDate
                    lastIgnoredValue = nil
                    lastAfterCancel?.dispose()
                    lastAfterCancel = nil
                    observer(result)                    
                    if latest {
                        lastAfterCancel = queue.jx_after(timeInterval: timeInterval) {
                            if let lastIgnoredValue = lastIgnoredValue {
                                observer(lastIgnoredValue)
                                lastUpdateTime = Date()
                            }
                            lastIgnoredValue = nil
                        }
                    }
                }
            }.with(disposable: DelegateDisposable {
                lastAfterCancel?.dispose()
                lastAfterCancel = nil
            })
        }
    }

    public func debounce(timeInterval: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Observer<ValueType> {
        return Observer { observer in
            var lastAfterCancel: Disposable? = nil
            return self.subscribe { result in
                lastAfterCancel?.dispose()
                
                lastAfterCancel = queue.jx_after(timeInterval: timeInterval) {
                    observer(result)
                }
            }.with(disposable: DelegateDisposable {
                lastAfterCancel?.dispose()
                lastAfterCancel = nil
            })
        }
    }

    
    public func skip(x: Int) -> Observer<ValueType> {
        return Observer { observer in
            var total = 0
            return self.subscribe { result in
                if total >= x {
                    observer(result)
                }
                total += 1
            }
        }
    }
    
    public func skip(last x: Int) -> Observer<ValueType> {
        return Observer { observer in
            var buffer: [ValueType] = []
            return self.subscribe { result in
                buffer.append(result)
                
                if buffer.count > x {
                    observer(buffer[0])
                    buffer.removeFirst()
                }
            }
        }
    }
    
    public func skip<T: Observable>(until: T) -> Observer<ValueType> {
        return Observer { observer in
            var canEmit = false
            
            let disposable = until.subscribe { _ in
                canEmit = true
            }
            return self.subscribe { result in
                if canEmit {
                    observer(result)
                }
            }.with(disposable: disposable)
        }
    }

    public func skip(while f: @escaping (ValueType)->Bool) -> Observer<ValueType> {
        return Observer { observer in
            var canEmit = false
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
        return Observer { observer in
            var counter = 0
            return self.subscribe { result in
                if counter < first {
                    observer(result)
                }
                counter += 1
            }
        }
    }
    
    public func take<T: Observable>(until: T) -> Observer<ValueType> {
        return Observer { observer in
            var canEmit = true
            
            let disposable = until.subscribe { _ in
                canEmit = false
            }
            return self.subscribe { result in
                if canEmit {
                    observer(result)
                }
            }.with(disposable: disposable)
        }
    }

    public func take(while f: @escaping (ValueType)->Bool) -> Observer<ValueType> {
        return Observer { observer in
            var canEmit = true
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
        return Observer { observer in
            var found = false
            return self.subscribe { result in
                if f(result) && !found {
                    found = true
                    observer(result)
                }
            }
        }
    }

    public func element(at index: Int) -> Observer<ValueType> {
        return Observer { observer in
            var currentIndex = 0
            return self.subscribe { result in
                if currentIndex == index {
                    observer(result)
                }
                currentIndex += 1
            }
        }
    }
    
    public func pausable<T: Observable>(_ controller: T) -> Observer<ValueType> where T.ValueType == Bool {
        return Observer { observer in
            var canEmit = false
            
            let disposable = controller.subscribe { result in
                canEmit = result
            }
            return self.subscribe { result in
                if canEmit {
                    observer(result)
                }
            }.with(disposable: disposable)
        }
    }

    public func pausableBuffered<T: Observable>(_ controller:T) -> Observer<ValueType> where T.ValueType == Bool {
        return Observer { observer in
            var canEmit = false
            var buffer: [ValueType] = []
            
            let disposable = controller.subscribe { result in
                canEmit = result
            }
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
    
        return Observer<ValueType> { observer in
            var lastValue: ValueType?
            
            func test(_ result: ValueType) -> ValueType? {
                if let lv = lastValue {
                    return (lv != result) ? result : nil
                } else {
                    lastValue = result
                    return result
                }
            }
            
            return self.subscribe { result in
                if let newValue = test(result) {
                    observer(newValue)
                }
            }
        }
    }
    
    public func equal(_ value: ValueType) -> Observer<ValueType> {
        return filter {
            ($0 == value)
        }
    }
    
    public func only(_ value: ValueType) -> Observer<Void> {
        return filter {
            ($0 == value)
        }.just
    }
    
    public func contains(where f: @escaping (ValueType)->Bool) -> Observer<Bool> {
        return Observer<Bool> { observer in
            var val = false
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
        return Observer<Int> { observer in
            var idx = 0
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
        return Observer { observer in
            var set = Set<ValueType>()
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
    
        return Observer { observer in
            var idx = 0
            return self.subscribe { result in
                if  f(result) {
                    observer(idx)
                }
                idx += 1
            }
        }
    }
}
