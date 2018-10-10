import UIKit


extension JetpackExtensions where Base: UITextView {
	
	public var text: Consumer<String?> {
        return jx_makeConsumer { $0.text = $1 }
	}

	public var attributedText: Consumer<NSAttributedString?> {
		return jx_makeConsumer { $0.attributedText = $1 }
	}

    public var textValues: Property<String?> {
        #if swift(>=4.2)
        return jx_makeNotificationProperty(key: #function, name: UITextView.textDidChangeNotification) { $0.text }
        #else
        return jx_makeNotificationProperty(key: #function, name: .UITextViewTextDidChange) { $0.text }
        #endif
    }
    
    public var attributedTextValues: Property<NSAttributedString?> {
        #if swift(>=4.2)
        return jx_makeNotificationProperty(key: #function, name: UITextView.textDidChangeNotification) { $0.attributedText }
        #else
        return jx_makeNotificationProperty(key: #function, name: .UITextViewTextDidChange) { $0.attributedText }
        #endif
    }    
}

