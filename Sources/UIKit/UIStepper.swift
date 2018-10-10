import UIKit

extension JetpackExtensions where Base: UIStepper {

	public var value: Binder<Double> {
        return jx_makeBinder { $0.value = $1 }
	}

	public var values: Property<Double> {
		return propertyControlEvents(.valueChanged) { $0.value }
	}
}
