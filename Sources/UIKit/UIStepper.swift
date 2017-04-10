import UIKit

extension Jetpack where Base: UIStepper {

	/// Sets the stepper's value.
	public var value: BindingTarget<Double> {
		return makeBindingTarget(key: "value") { $0.value = $1 }
	}

	/// A signal of double values emitted by the stepper upon each user's
	/// interaction.
	public var values: Property<Double> {
		return propertyControlEvents(.valueChanged) { $0.value }
	}
}
