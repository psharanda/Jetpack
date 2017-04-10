//
//  Created by Pavel Sharanda on 17.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

private var NSObject_jx_objects: UInt8 = 0

extension NSObject {
    
    var jx_objects: NSMutableDictionary {
        switch (objc_getAssociatedObject(self, &NSObject_jx_objects) as? NSMutableDictionary) {
        case .some(let p):
            return p
        case .none:
            let dict = NSMutableDictionary()
            objc_setAssociatedObject(self, &NSObject_jx_objects, dict, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return dict
        }
    }
    
    public func jx_reset() {
        jx_objects.removeAllObjects()
    }
    
    public func jx_lazyObject<U>(key: String, creator: (()->U)) -> U {
        if let val = jx_objects.object(forKey: key), let obj = val as? U {
            return obj
        } else {
            let object = creator()
            jx_objects.setObject(object, forKey: key as NSCopying)
            return object
        }
    }
    
    public func jx_lazyBindingTarget<T>(key: String, setter: @escaping (T)->Void) -> BindingTarget<T> {
        return jx_lazyObject(key: key) {
            return BindingTarget<T>(setter: setter)
        }
    }
    
    public func jx_lazySignal<T>(key: String, setup: (Signal<T>)->Void = {_ in }) -> Signal<T> {
        return jx_lazyObject(key: key) {
            let signal = Signal<T>()
            setup(signal)
            return signal
        }
    }
    
    public func jx_lazyMutableProperty<T>(key: String, initialValue: T, setup: (MutableProperty<T>)->Void = {_ in }) -> MutableProperty<T> {
        return jx_lazyObject(key: key) {
            let property = MutableProperty<T>(initialValue)
            setup(property)
            return property
        }
    }
    
    public func jx_lazyState<T>(key: String, initialValue: T, onChange: @escaping (T, T)->Void = {_ in }) -> State<T> {
        return jx_lazyObject(key: key) {
            return State<T>(initialValue, onChange: onChange)
        }
    }
}

extension Jetpack where Base: NSObject {
    
    ///   A binding target that holds no strong references to the object.
    public func makeBindingTarget<U>(key: String, _ action: @escaping (Base, U)->Void) -> BindingTarget<U> {
        return base.jx_lazyBindingTarget(key: key) { [weak base] value in
            if let base = base {
                action(base, value)
            }
        }
    }
    
    public func makeObservable<T>(key: String, setup: (Base, AnyObject, Selector, Signal<T>)->Void, update: @escaping (Base)->T) -> Observable<T> {
        return base.jx_lazyObject(key: key) { () -> SignalActionHandler<Base, T> in
            let controlHandler = SignalActionHandler(key: key, base: base, update: update)
            setup(base, controlHandler, #selector(SignalActionHandler<Base, T>.jx_handleAction), controlHandler.signal)
            return controlHandler
        }.signal
    }
    
    public func makeProperty<T>(key: String, setup: (Base, AnyObject, Selector, MutableProperty<T>)->Void, update: @escaping (Base)->T) -> Property<T> {
        return base.jx_lazyObject(key: key) { () -> PropertyActionHandler<Base, T> in
            let controlHandler = PropertyActionHandler(key: key, base: base, update: update)
            setup(base, controlHandler, #selector(PropertyActionHandler<Base, T>.jx_handleAction), controlHandler.property)
            return controlHandler
        }.property
    }
}

extension NSObject: JetpackExtensionsProvider {}

fileprivate class SignalActionHandler<Base: AnyObject, T>: NSObject {
    
    let signal = Signal<T>()
    let update: (Base)->T
    unowned let base: Base
    let key: String
    
    init(key: String, base: Base, update: @escaping (Base)->T) {
        self.key = key
        self.update = update
        self.base = base
    }
    
    @objc func jx_handleAction() {
        signal.update(update(base))
    }
}

fileprivate class PropertyActionHandler<Base: AnyObject, T>: NSObject {
    
    let property: MutableProperty<T>
    let update: (Base)->T
    unowned let base: Base
    let key: String
    
    init(key: String, base: Base, update: @escaping (Base)->T) {
        self.key = key
        self.update = update
        self.base = base
        property = MutableProperty(update(base))
    }
    
    @objc func jx_handleAction() {
        property.update(update(base))
    }
}
