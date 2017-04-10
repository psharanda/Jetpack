import UIKit


extension Jetpack where Base: UITextView {
	/// Sets the text of the text view.
	public var text: BindingTarget<String?> {
        return makeBindingTarget(key: "text") { $0.text = $1 }
	}
	
	/// Sets the attributed text of the text view.
	public var attributedText: BindingTarget<NSAttributedString?> {
		return makeBindingTarget(key: "attributedText") { $0.attributedText = $1 }
	}

    /// A signal of text values emitted by the text field upon any changes.
    public var textValues: Property<String?> {
        fatalError("Not implemented")
    }
    
    /// A signal of attributed text values emitted by the text field upon any changes.
    public var attributedTextValues: Property<NSAttributedString?> {
        fatalError("Not implemented")
    }
    
}
