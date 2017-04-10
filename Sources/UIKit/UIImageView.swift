import UIKit

extension Jetpack where Base: UIImageView {
	/// Sets the image of the image view.
	public var image: BindingTarget<UIImage?> {
		return makeBindingTarget(key: "image") { $0.image = $1 }
	}

	/// Sets the image of the image view for its highlighted state.
	public var highlightedImage: BindingTarget<UIImage?> {
		return makeBindingTarget(key: "highlightedImage") { $0.highlightedImage = $1 }
	}
}
