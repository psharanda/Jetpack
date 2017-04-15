import UIKit

fileprivate func controlEventsKey(_ controlEvents: UIControlEvents) -> String {
    return "\(#function) \(controlEvents.rawValue)"
}

extension Jetpack where Base: UIControl {

    public func signalControlEvents<T>(_ controlEvents: UIControlEvents, getter: @escaping (Base)->T) -> Observer<T> {
        let key = controlEventsKey(controlEvents)
    
        return makeTargetActionObserver(key: key, setup: { base, target, action in
            base.addTarget(target, action: action, for: controlEvents)
        }, cleanup: { base, target, action in
            base.removeTarget(target, action: action, for: controlEvents)
        }, getter: getter)
        
	}
    
    public func propertyControlEvents<T>(_ controlEvents: UIControlEvents, getter: @escaping (Base)->T) -> Property<T> {
        let key = controlEventsKey(controlEvents)
        
        return makeTargetActionProperty(key: key, setup: { base, target, action in
            base.addTarget(target, action: action, for: controlEvents)
        }, cleanup: { base, target, action in
            base.removeTarget(target, action: action, for: controlEvents)
        }, getter: getter)
    }

	public var isEnabled: Receiver<Bool> {
        return makeReceiver(key: #function) { $0.isEnabled = $1 }
	}

	public var isSelected: Receiver<Bool> {
		return makeReceiver(key: #function) { $0.isSelected = $1 }
	}

	public var isHighlighted: Receiver<Bool> {
		return makeReceiver(key: #function) { $0.isHighlighted = $1 }
	}
}


