import UIKit

extension Jetpack where Base: UIProgressView {
	/// Sets the relative progress to be reflected by the progress view.
	public var progress: BindingTarget<Float> {
		return makeBindingTarget(key: "progress") { $0.progress = $1 }
	}
}
