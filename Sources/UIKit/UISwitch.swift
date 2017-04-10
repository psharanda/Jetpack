import UIKit

extension Jetpack where Base: UISwitch {

	public var isOn: Receiver<Bool> {
        return makeReceiver(key: #function) { $0.isOn = $1 }
	}

	public var values: Property<Bool> {
		return propertyControlEvents(.valueChanged) { $0.isOn }
	}
}
