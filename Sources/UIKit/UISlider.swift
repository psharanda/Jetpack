import UIKit

extension JetpackExtensions where Base: UISlider {

	public var value: Binder<Float> {
        return jx_makeBinder { $0.value = $1 }
	}

	public var values: Property<Float> {
		return propertyControlEvents(.valueChanged) { $0.value }
	}
}
