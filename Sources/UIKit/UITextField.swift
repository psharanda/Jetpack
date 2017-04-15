import UIKit

extension JetpackExtensions where Base: UITextField {
	
	public var text: Receiver<String?> {
        return makeReceiver(key: #function) { $0.text = $1 }
	}
    
    public var attributedText: Receiver<NSAttributedString?> {
        return makeReceiver(key: #function) { $0.attributedText = $1 }
    }

	public var textValues: Property<String?> {
		return propertyControlEvents(.editingChanged) { $0.text }
	}

	public var attributedTextValues: Property<NSAttributedString?> {
		return propertyControlEvents(.editingChanged) { $0.attributedText }
	}
	
}
