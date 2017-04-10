//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

enum TaskCompletionState {
    case cancelled
    case finished
}

public protocol Cancelable: class {
    func cancel()
}

///observable which is expected to be completed, completion as state is not defined
public class Task<T>: Observable<T>, Cancelable {
    
    internal lazy var completion: Observable<TaskCompletionState> = self._completion
    
    private let _completion = Signal<TaskCompletionState>()
    private var _cancelable: Cancelable?
    
    
    // first param is generator, second completion
    public init(worker: @escaping (@escaping (T)->Void, @escaping ()->Void )->Cancelable?) {
        super.init()
        _cancelable = worker({[weak self] (newValue) in
            self?.rawUpdate(newValue)
            }, { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf._cancelable = nil //we are finished at this moment, no need to keep cancelable (resource)
                
                if strongSelf._completion.lastValue == nil {
                    strongSelf._completion.update(.finished)
                }
        })
    }
    
    deinit {
        cancel()
    }
    
    public func cancel() {
        _cancelable?.cancel()
        _cancelable = nil
        
        if _completion.lastValue == nil {
            _completion.update(.cancelled)
        }
    }
}

extension Task {
    public convenience init(completed: T) {
        self.init { generator, completion in
            generator(completed)
            completion()
            return nil
        }
    }
    
    public convenience init<U>(from: U, processor: @escaping (U)->T, processingQueue: DispatchQueue, resultsQueue: DispatchQueue = DispatchQueue.main) {
        self.init(startWith: nil, from: from, processor: processor, processingQueue: processingQueue, resultsQueue: resultsQueue)
    }
    
    public convenience init<U>(from: U, processor: @escaping (U)->T) {
        self.init(startWith: nil, from: from, processor: processor, processingQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.background))
    }
    
    public convenience init<U>(startWith: T?, from: U, processor: @escaping (U)->T, processingQueue: DispatchQueue, resultsQueue: DispatchQueue = DispatchQueue.main) {
        self.init { generator, completion in
            if let startWith = startWith {
                generator(startWith)
            }
            processingQueue.async {
                let res = processor(from)
                
                resultsQueue.async {
                    generator(res)
                    completion()
                }
            }
            return nil
        }
    }
    
    public convenience init<U>(startWith: T?, from: U, processor: @escaping (U)->T) {
        self.init(startWith: startWith, from: from, processor: processor, processingQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.background))
    }
}
