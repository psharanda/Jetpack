#if os(iOS)

import UIKit

extension JetpackExtensions where Base: UISlider {

	public var value: Consumer<Float> {
        return jx_makeConsumer { $0.value = $1 }
	}

	public var values: Property<Float> {
		return propertyControlEvents(.valueChanged) { $0.value }
	}
}

#endif
