import UIKit


extension Jetpack where Base: UITextView {
	
	public var text: Receiver<String?> {
        return makeReceiver(key: #function) { $0.text = $1 }
	}

	public var attributedText: Receiver<NSAttributedString?> {
		return makeReceiver(key: #function) { $0.attributedText = $1 }
	}

    public var textValues: Property<String?> {
        fatalError("Not implemented")
    }
    
    public var attributedTextValues: Property<NSAttributedString?> {
        fatalError("Not implemented")
    }
    
}
