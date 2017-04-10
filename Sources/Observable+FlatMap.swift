//
//  Created by Pavel Sharanda on 20.03.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

extension Observable {
    @discardableResult
    public func flatMap<U>(_ f: @escaping ((T) -> U?)) -> Observable<U> {
        let signal = Signal<U>()
        subscribe { result in
            if let mr = f(result) {
                signal.update(mr)
            }
        }
        return signal
    }
    
    @discardableResult
    public func flatMapLatest<U>(_ f: @escaping ((T) -> Observable<U>?)) -> Observable<U> {
        
        let signal = Signal<U>()
        
        var observable: Observable<U>?
        
        subscribe { result in
            
            if let ob = f(result) {
                
                observable = ob
                
                observable?.subscribe {[weak signal] innerResult in
                    guard let signal = signal else { return }
                    signal.update(innerResult)
                }
            }
        }
        return signal
    }
    
    @discardableResult
    public func flatMapMerge<U>(_ f: @escaping ((T) -> Observable<U>?)) -> Observable<U> {
        
        let signal = Signal<U>()
        
        var observables: [Observable<U>] = []
        
        subscribe { result in
            
            if let ob = f(result) {
                observables.append(ob)
                ob.subscribe {[weak signal] innerResult in
                    guard let signal = signal else { return }
                    signal.update(innerResult)
                }
            }
        }
        return signal
    }
    
    @discardableResult
    public func flatMapCombine<U>(_ f: @escaping ((T) -> Observable<U>?)) -> Observable<[U?]> {
        
        let signal = Signal<[U?]>()
        
        var observables: [Observable<U>] = []
        
        
        subscribe { result in
            
            if let ob = f(result) {
                observables.append(ob)
                ob.subscribe {[weak signal] innerResult in
                    guard let signal = signal else { return }
                    signal.update(observables.map { $0.lastValue} )
                }
            }
        }
        return signal
    }
    
    @discardableResult
    public func flatMapLatestTask<U>(_ f: @escaping ((T) -> Task<U>?)) -> TaskHolder<U> {
        let taskHolder = TaskHolder<U>()
        
        subscribe { result in
            
            if let task = f(result) {
                
                taskHolder.task = task
                
                taskHolder.task?.subscribe {[weak taskHolder] innerResult in
                    taskHolder?.rawUpdate(innerResult)
                }
                
                taskHolder.task?.completion.subscribe {[weak taskHolder] completed in
                    taskHolder?.task = nil
                }
            }
            
        }
        return taskHolder
    }
    
    @discardableResult
    public func flatMapLatestRetriableTask<U>(_ f: @escaping ((T) -> Task<U>?)) -> RetriableTaskHolder<U> {
        let taskHolder = RetriableTaskHolder<U>()
        
        subscribe { result in
            
            func taskCreator() -> Task<U>? {
                return f(result)
            }
            
            taskHolder.taskCreator = taskCreator
        }
        return taskHolder
    }
}
