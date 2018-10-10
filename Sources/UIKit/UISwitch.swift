import UIKit

extension JetpackExtensions where Base: UISwitch {

	public var isOn: Consumer<Bool> {
        return jx_makeConsumer { $0.isOn = $1 }
	}

	public var isOnValues: Property<Bool> {
		return propertyControlEvents(.valueChanged) { $0.isOn }
	}
}
