import UIKit

extension Jetpack where Base: UISlider {

	/// Sets slider's value.
	public var value: BindingTarget<Float> {
		return makeBindingTarget(key: "value") { $0.value = $1 }
	}

	/// A signal of float values emitted by the slider while being dragged by
	/// the user.
	///
	/// - note: If slider's `isContinuous` property is `false` then values are
	///         sent only when user releases the slider.
	public var values: Property<Float> {
		return propertyControlEvents(.valueChanged) { $0.value }
	}
}
