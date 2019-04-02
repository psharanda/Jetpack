#if os(iOS) || os(tvOS)

import UIKit

extension JetpackExtensions where Base: UISegmentedControl {

	public var selectedSegmentIndex: Consumer<Int> {
        return jx_makeConsumer { $0.selectedSegmentIndex = $1 }
	}

	public var selectedSegmentIndexValues: Property<Int> {
		return propertyControlEvents(.valueChanged) { $0.selectedSegmentIndex }
	}
}

#endif
