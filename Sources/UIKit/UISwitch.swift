import UIKit

extension Jetpack where Base: UISwitch {

	/// Sets the on-off state of the switch.
	public var isOn: BindingTarget<Bool> {
		return makeBindingTarget(key: "isOn") { $0.isOn = $1 }
	}

	/// A signal of on-off states in `Bool` emitted by the switch.
	public var values: Property<Bool> {
		return propertyControlEvents(.valueChanged) { $0.isOn }
	}
}
