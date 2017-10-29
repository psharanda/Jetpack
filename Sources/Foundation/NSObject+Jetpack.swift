//
//  Created by Pavel Sharanda on 17.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

private var NSObject_jx_objects: UInt8 = 0

extension JetpackExtensions where Base: NSObject {
    
    private var jx_objects: NSMutableDictionary {
        switch (objc_getAssociatedObject(base, &NSObject_jx_objects) as? NSMutableDictionary) {
        case .some(let p):
            return p
        case .none:
            let dict = NSMutableDictionary()
            objc_setAssociatedObject(base, &NSObject_jx_objects, dict, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return dict
        }
    }
    
    func jx_lazyObject<U>(key: String, creator: (()->U)) -> U {
        if let val = jx_object(forKey: key), let obj = val as? U {
            return obj
        } else {
            let object = creator()
            jx_setObject(object, forKey: key)
            return object
        }
    }
    
    func jx_setObject(_ object: Any, forKey key: String){
        jx_objects.setObject(object, forKey: key as NSString)
    }
    
    func jx_object(forKey key: String) -> Any? {
        return jx_objects.object(forKey: key as NSString)
    }
    
    func jx_removeObject(forKey key: String){
        jx_objects.removeObject(forKey: key as NSString)
    }
    
    func jx_makeReceiver<U>(action: @escaping (Base, U)->Void) -> Receiver<U> {
        return Receiver {[weak base] value in
            if let base = base {
                action(base, value)
            }                
        }
    }
    
    func jx_makeTargetActionObservable<T>(setup: @escaping (Base, AnyObject, Selector)->Void,
                                   cleanup: @escaping (Base, AnyObject, Selector)->Void,
                                   getter: @escaping (Base)->T) -> Observable<T> {
        
        
        
        return Observable {
            let target = ActionTarget(base: self.base, observer: $0, getter: getter)
            let key = ObjectIdentifier(target).debugDescription
            let action = #selector(ActionTarget<Base, T>.handleEvent)
            setup(self.base, target, action)
            
            self.base.jx.jx_setObject(target, forKey: key)
            
            return DelegateDisposable {
                cleanup(self.base, target, action)
                self.base.jx.jx_removeObject(forKey: key)
            }
        }
    }
    
    func jx_makeTargetActionProperty<T>(setup: @escaping (Base, AnyObject, Selector)->Void,
                                        cleanup: @escaping (Base, AnyObject, Selector)->Void,
                                        getter: @escaping (Base)->T) -> Property<T> {
        let observable = jx_makeTargetActionObservable(setup: setup, cleanup: cleanup, getter: getter)
        return Property(observable) {
            getter(self.base)
        }
    }
    
    func jx_makeNotificationProperty<T>(key: String,
                                  name: Notification.Name,
                                  getter: @escaping (Base)->T) -> Property<T> {
        let observable = Observable<T> {
            let target = NotificationTarget(base: self.base, observer: $0, getter: getter)
            let key = ObjectIdentifier(target).debugDescription
            let action = #selector(NotificationTarget<Base, T>.handleNotification(notification:))
            NotificationCenter.default.addObserver(target, selector: action, name: name, object: nil)
            
            self.base.jx.jx_setObject(target, forKey: key)
            
            return DelegateDisposable {
                NotificationCenter.default.removeObserver(target)
                self.base.jx.jx_removeObject(forKey: key)
            }
        }
        
        return Property(observable) {
            getter(self.base)
        }
    }
    
    public var autodisposePool: AutodisposePool {
        return autodisposePool(for: "")
    }
    
    public func autodisposePool(for key: String) -> AutodisposePool {
        return jx_lazyObject(key: #function + key) {
            return AutodisposePool()
        }
    }
}

extension NSObject: JetpackExtensionsProvider {}

class ActionTarget<Base: AnyObject, T>: NSObject {
    let observer: (T) -> Void
    let getter: (Base) -> T
    unowned let base: Base
    
    init(base: Base, observer: @escaping (T) -> Void, getter: @escaping (Base)->T) {
        self.observer = observer
        self.getter = getter
        self.base = base
    }
    
    @objc func handleEvent() {
        observer(getter(base))
    }
}

class NotificationTarget<Base: AnyObject, T>: NSObject {
    let observer: (T) -> Void
    let getter: (Base) -> T
    unowned let base: Base
    
    init(base: Base, observer: @escaping (T) -> Void, getter: @escaping (Base)->T) {
        self.observer = observer
        self.getter = getter
        self.base = base
    }
    
    @objc func handleNotification(notification: Notification) {
        if let any = notification.object, let object = any as? Base, base === object {
            observer(getter(base))
        }
    }
}
