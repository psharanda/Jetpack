import UIKit

extension JetpackExtensions where Base: UIStepper {

	public var value: Receiver<Double> {
        return jx_makeReceiver(key: #function) { $0.value = $1 }
	}

	public var values: Property<Double> {
		return propertyControlEvents(.valueChanged) { $0.value }
	}
}
