import UIKit

extension Jetpack where Base: UIBarItem {
	/// Sets whether the bar item is enabled.
	public var isEnabled: BindingTarget<Bool> {
		return makeBindingTarget(key: "isEnabled") { $0.isEnabled = $1 }
	}

	/// Sets image of bar item.
	public var image: BindingTarget<UIImage?> {
		return makeBindingTarget(key: "image") { $0.image = $1 }
	}

	/// Sets the title of bar item.
	public var title: BindingTarget<String?> {
		return makeBindingTarget(key: "title") { $0.title = $1 }
	}
}
