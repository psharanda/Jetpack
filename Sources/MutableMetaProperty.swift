//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

open class MutableMetaProperty<T, Event: ChangeEventProtocol>: ObserveValueProtocol, GetValueProtocol, UpdateValueProtocol, MutateValueProtocol  {
    
    private var _value: T
    private let innerUnsafeSubject = UnsafeSubject<(T, Event)>()
    private let subjectLock = Lock()
    private let valueLock = Lock()
    private let mutateLock = Lock()

    public init(_ value: T) {
        _value = value
    }
    
    public var value: T {
        get {
            valueLock.synchronized {
                return _value
            }
        }
        set {
            mutate { $0 = newValue }
        }
    }

    public func subscribe(_ observer: @escaping ((T, Event)) -> Void) -> Disposable {
        subjectLock.synchronized {
            observer((_value, .resetEvent))
            return innerUnsafeSubject.subscribe(observer).locked(with: subjectLock)
        }
    }
    
    public func update(_ newValue: T) {
        mutate { $0 = newValue }
    }
    
    public func mutate(_ transform: (inout T) -> ()) {
        mutateWithEvent {
            transform(&$0)
            return .resetEvent
        }
    }

    public func mutateWithEvent(_ transform: (inout T)-> Event) {
        mutateLock.synchronized {
            
            let (newValue, newEvent): (T, Event
                ) =  valueLock.synchronized {
                let event = transform(&_value)
                return ( _value, event)
            }

            subjectLock.synchronized {
                innerUnsafeSubject.update((newValue, newEvent))
            }
        }        
    }
    
    public var asMetaProperty: MetaProperty<T, Event> {
        return MetaProperty(observable: asObservable) { self.value }
    }

    public var asMainThreadMetaProperty: MetaProperty<T, Event> {
        return MetaProperty(observable: dispatch(on: .main)) { self.value }
    }
}
