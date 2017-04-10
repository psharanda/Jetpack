import UIKit

extension Jetpack where Base: UIView {
	/// Sets the alpha value of the view.
	public var alpha: BindingTarget<CGFloat> {
        return makeBindingTarget(key: "alpha") { $0.alpha = $1 }
	}

	/// Sets whether the view is hidden.
	public var isHidden: BindingTarget<Bool> {
		return makeBindingTarget(key: "isHidden") { $0.isHidden = $1 }
	}

	/// Sets whether the view accepts user interactions.
	public var isUserInteractionEnabled: BindingTarget<Bool> {
		return makeBindingTarget(key: "isUserInteractionEnabled") { $0.isUserInteractionEnabled = $1 }
	}
}
