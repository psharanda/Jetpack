#if os(iOS) || os(tvOS)

import UIKit

extension JetpackExtensions where Base: UITextField {
	
	public var text: Consumer<String?> {
        return jx_makeConsumer { $0.text = $1 }
	}
    
    public var attributedText: Consumer<NSAttributedString?> {
        return jx_makeConsumer { $0.attributedText = $1 }
    }

	public var textValues: Property<String?> {
		return propertyControlEvents(.editingChanged) { $0.text }
	}

	public var attributedTextValues: Property<NSAttributedString?> {
		return propertyControlEvents(.editingChanged) { $0.attributedText }
	}
	
}

#endif
