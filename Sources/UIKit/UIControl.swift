import UIKit

fileprivate func controlEventsKey(_ controlEvents: UIControlEvents) -> String {
    return "controlEventsKey \(controlEvents.rawValue)"
}

extension Jetpack where Base: UIControl {

    /// Create a signal which sends a `value` event for each of the specified
    /// control events.
    public func signalControlEvents<T>(_ controlEvents: UIControlEvents, update: @escaping (Base)->T) -> Observable<T> {
        let key = controlEventsKey(controlEvents)
        
        return makeObservable(key: key, setup: { base, target, action, _ in
            base.addTarget(target, action: action, for: controlEvents)
        }, update: update)
	}
    
    public func propertyControlEvents<T>(_ controlEvents: UIControlEvents, update: @escaping (Base)->T) -> Property<T> {
        let key = controlEventsKey(controlEvents)
        
        return makeProperty(key: key, setup: { base, target, action, _ in
            base.addTarget(target, action: action, for: controlEvents)
        }, update: update)
    }

	/// Sets whether the control is enabled.
	public var isEnabled: BindingTarget<Bool> {
		return makeBindingTarget(key: "isEnabled") { $0.isEnabled = $1 }
	}

	/// Sets whether the control is selected.
	public var isSelected: BindingTarget<Bool> {
		return makeBindingTarget(key: "isSelected") { $0.isSelected = $1 }
	}

	/// Sets whether the control is highlighted.
	public var isHighlighted: BindingTarget<Bool> {
		return makeBindingTarget(key: "isHighlighted") { $0.isHighlighted = $1 }
	}
}


