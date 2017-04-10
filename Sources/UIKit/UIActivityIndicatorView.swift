import UIKit

extension Jetpack where Base: UIActivityIndicatorView {
	/// Sets whether the activity indicator should be animating.
	public var isAnimating: BindingTarget<Bool> {
		return makeBindingTarget(key: "isAnimating") { $1 ? $0.startAnimating() : $0.stopAnimating() }
	}
}
