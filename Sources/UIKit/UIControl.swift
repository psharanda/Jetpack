import UIKit

fileprivate func controlEventsKey(_ controlEvents: UIControlEvents) -> String {
    return "\(#function) \(controlEvents.rawValue)"
}



extension JetpackExtensions where Base: UIControl {

    public func controlEventDidFire(_ controlEvents: UIControlEvents) -> Observable<Void> {
        return jx_makeTargetActionObservable(setup: { base, target, action in
            base.addTarget(target, action: action, for: controlEvents)
        }, cleanup: { base, target, action in
            base.removeTarget(target, action: action, for: controlEvents)
        }, getter: { _ in })
	}
    
    public func propertyControlEvents<T>(_ controlEvents: UIControlEvents, getter: @escaping (Base)->T) -> Property<T> {
        return jx_makeTargetActionProperty(setup: { base, target, action in
            base.addTarget(target, action: action, for: controlEvents)
        }, cleanup: { base, target, action in
            base.removeTarget(target, action: action, for: controlEvents)
        }, getter: getter)
    }

	public var isEnabled: Receiver<Bool> {
        return jx_makeReceiver { $0.isEnabled = $1 }
	}

	public var isSelected: Receiver<Bool> {
		return jx_makeReceiver { $0.isSelected = $1 }
	}

	public var isHighlighted: Receiver<Bool> {
		return jx_makeReceiver { $0.isHighlighted = $1 }
	}
}


