import UIKit

extension Jetpack where Base: UILabel {
	/// Sets the text of the label.
	public var text: BindingTarget<String?> {
		return makeBindingTarget(key: "text") { $0.text = $1 }
	}

	/// Sets the attributed text of the label.
	public var attributedText: BindingTarget<NSAttributedString?> {
		return makeBindingTarget(key: "attributedText") { $0.attributedText = $1 }
	}
}
