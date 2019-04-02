#if os(iOS) || os(tvOS)

import UIKit

#if swift(>=4.2)
public typealias ControlEvents = UIControl.Event
public typealias ControlState = UIControl.State
#else
public typealias ControlEvents = UIControlEvents
public typealias ControlState = UIControlState
#endif

fileprivate func controlEventsKey(_ controlEvents: ControlEvents) -> String {
    return "\(#function) \(controlEvents.rawValue)"
}



extension JetpackExtensions where Base: UIControl {

    public func controlEvents(_ controlEvents: ControlEvents) -> Observable<Void> {
        return jx_makeTargetActionObservable(setup: { base, target, action in
            base.addTarget(target, action: action, for: controlEvents)
        }, cleanup: { base, target, action in
            base.removeTarget(target, action: action, for: controlEvents)
        }, getter: { _ in })
	}
    
    public func propertyControlEvents<T>(_ controlEvents: ControlEvents, getter: @escaping (Base)->T) -> Property<T> {
        return jx_makeTargetActionProperty(setup: { base, target, action in
            base.addTarget(target, action: action, for: controlEvents)
        }, cleanup: { base, target, action in
            base.removeTarget(target, action: action, for: controlEvents)
        }, getter: getter)
    }

	public var isEnabled: Consumer<Bool> {
        return jx_makeConsumer { $0.isEnabled = $1 }
	}

	public var isSelected: Consumer<Bool> {
		return jx_makeConsumer { $0.isSelected = $1 }
	}

	public var isHighlighted: Consumer<Bool> {
		return jx_makeConsumer { $0.isHighlighted = $1 }
	}
}

#endif
