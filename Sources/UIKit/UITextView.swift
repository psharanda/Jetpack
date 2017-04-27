import UIKit


extension JetpackExtensions where Base: UITextView {
	
	public var text: Receiver<String?> {
        return makeReceiver(key: #function) { $0.text = $1 }
	}

	public var attributedText: Receiver<NSAttributedString?> {
		return makeReceiver(key: #function) { $0.attributedText = $1 }
	}

    public var textValues: Property<String?> {
        return makeNotificationProperty(key: #function, name: .UITextViewTextDidChange) { $0.text }
    }
    
    public var attributedTextValues: Property<NSAttributedString?> {
        return makeNotificationProperty(key: #function, name: .UITextViewTextDidChange) { $0.attributedText }
    }
    
}

