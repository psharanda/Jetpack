//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension ObservableProtocol {
    
    public func filter(_ isIncluded: @escaping (ValueType) -> Bool) -> Observable<ValueType> {
        return flatMap {
            isIncluded($0) ? $0 : nil
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

    public func throttle(timeInterval: TimeInterval, latest: Bool = true, queue: DispatchQueue = DispatchQueue.main) -> Observable<ValueType> {
        return Observable { observer in
            
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
                        lastAfterCancel = queue.jx.after(timeInterval: timeInterval) {
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

    public func debounce(timeInterval: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Observable<ValueType> {
        return Observable { observer in
            var lastAfterCancel: Disposable? = nil
            return self.subscribe { result in
                lastAfterCancel?.dispose()
                
                lastAfterCancel = queue.jx.after(timeInterval: timeInterval) {
                    observer(result)
                }
            }.with(disposable: DelegateDisposable {
                lastAfterCancel?.dispose()
                lastAfterCancel = nil
            })
        }
    }

    
    public func skip(x: Int) -> Observable<ValueType> {
        return Observable { observer in
            var total = 0
            return self.subscribe { result in
                if total >= x {
                    observer(result)
                }
                total += 1
            }
        }
    }
    
    public func skip(last x: Int) -> Observable<ValueType> {
        return Observable { observer in
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
    
    public func skip<T: ObservableProtocol>(until: T) -> Observable<ValueType> {
        return Observable { observer in
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

    public func skip(while f: @escaping (ValueType)->Bool) -> Observable<ValueType> {
        return Observable { observer in
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

    public var first: Observable<ValueType> {
        return take(first: 1)
    }
    
    public func take(first: Int) -> Observable<ValueType> {
        return Observable { observer in
            var counter = 0
            return self.subscribe { result in
                if counter < first {
                    observer(result)
                }
                counter += 1
            }
        }
    }
    
    public func take<T: ObservableProtocol>(until: T) -> Observable<ValueType> {
        return Observable { observer in
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

    public func take(while f: @escaping (ValueType)->Bool) -> Observable<ValueType> {
        return Observable { observer in
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
    
    public func find(_ f: @escaping (ValueType) -> Bool) -> Observable<ValueType> {
        return Observable { observer in
            var found = false
            return self.subscribe { result in
                if f(result) && !found {
                    found = true
                    observer(result)
                }
            }
        }
    }

    public func element(at index: Int) -> Observable<ValueType> {
        return Observable { observer in
            var currentIndex = 0
            return self.subscribe { result in
                if currentIndex == index {
                    observer(result)
                }
                currentIndex += 1
            }
        }
    }
    
    public func pausable<T: ObservableProtocol>(_ controller: T) -> Observable<ValueType> where T.ValueType == Bool {
        return Observable { observer in
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

    public func pausableBuffered<T: ObservableProtocol>(_ controller:T) -> Observable<ValueType> where T.ValueType == Bool {
        return Observable { observer in
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

public extension ObservableProtocol where ValueType: Equatable {
    
    public var distinct: Observable<ValueType> {
    
        return Observable<ValueType> { observer in
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
    
    public func equal(_ value: ValueType) -> Observable<ValueType> {
        return filter {
            ($0 == value)
        }
    }
    
    public func only(_ value: ValueType) -> Observable<Void> {
        return filter {
            ($0 == value)
        }.just
    }
    
    public func contains(where f: @escaping (ValueType)->Bool) -> Observable<Bool> {
        return Observable<Bool> { observer in
            var val = false
            return self.subscribe { result in
                if !val && f(result) {
                    val = true
                    observer(val)
                }
            }
        }
    }
    
    public func contains(_ value: ValueType) -> Observable<Bool> {
        return contains { value == $0 }
    }
    
    public func findIndex(of value: ValueType) -> Observable<Int> {
        return Observable<Int> { observer in
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

extension ObservableProtocol where ValueType: Hashable {
    
    public var unique: Observable<ValueType> {
        return Observable { observer in
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

extension ObservableProtocol {
    
    public func findIndex(_ f: @escaping ((ValueType) -> Bool)) -> Observable<Int> {
    
        return Observable { observer in
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
