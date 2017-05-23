import UIKit

extension JetpackExtensions where Base: UISlider {

	public var value: Receiver<Float> {
        return jx_makeReceiver(key: #function) { $0.value = $1 }
	}

	public var values: Property<Float> {
		return propertyControlEvents(.valueChanged) { $0.value }
	}
}
