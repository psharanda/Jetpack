import UIKit

extension Jetpack where Base: UITextField {
	/// Sets the text of the text field.
	public var text: BindingTarget<String?> {
        return makeBindingTarget(key: "text") { $0.text = $1 }
	}
    
    /// Sets the attributed text of the text field.
    public var attributedText: BindingTarget<NSAttributedString?> {
        return makeBindingTarget(key: "attributedText") { $0.attributedText = $1 }
    }

	/// A signal of text values emitted by the text field upon any changes
	public var textValues: Property<String?> {
		return propertyControlEvents(.editingChanged) { $0.text }
	}
	
	/// A signal of attributed text values emitted by the text field upon any changes
	public var attributedTextValues: Property<NSAttributedString?> {
		return propertyControlEvents(.editingChanged) { $0.attributedText }
	}
	
}
