import UIKit

extension Jetpack where Base: UISegmentedControl {
	/// Changes the selected segment of the segmented control.
	public var selectedSegmentIndex: BindingTarget<Int> {
		return makeBindingTarget(key: "selectedSegmentIndex") { $0.selectedSegmentIndex = $1 }
	}

	/// A signal of indexes of selections emitted by the segmented control.
	public var selectedSegmentValues: Property<Int> {
		return propertyControlEvents(.valueChanged) { $0.selectedSegmentIndex }
	}
}
