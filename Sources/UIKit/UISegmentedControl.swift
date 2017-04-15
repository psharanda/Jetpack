import UIKit

extension JetpackExtensions where Base: UISegmentedControl {

	public var selectedSegmentIndex: Receiver<Int> {
        return makeReceiver(key: #function) { $0.selectedSegmentIndex = $1 }
	}

	public var selectedSegmentIndexValues: Property<Int> {
		return propertyControlEvents(.valueChanged) { $0.selectedSegmentIndex }
	}
}
