import UIKit

extension JetpackExtensions where Base: UISegmentedControl {

	public var selectedSegmentIndex: Binder<Int> {
        return jx_makeBinder { $0.selectedSegmentIndex = $1 }
	}

	public var selectedSegmentIndexValues: Property<Int> {
		return propertyControlEvents(.valueChanged) { $0.selectedSegmentIndex }
	}
}
