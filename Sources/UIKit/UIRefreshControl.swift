import UIKit

extension Jetpack where Base: UIRefreshControl {
	/// Sets whether the refresh control should be refreshing.
	public var isRefreshing: BindingTarget<Bool> {
		return makeBindingTarget(key: "isRefreshing") { $1 ? $0.beginRefreshing() : $0.endRefreshing() }
	}

	/// Sets the attributed title of the refresh control.
	public var attributedTitle: BindingTarget<NSAttributedString?> {
		return makeBindingTarget(key: "attributedTitle") { $0.attributedTitle = $1 }
	}
    
    /// A signal of on-off states in `Bool` emitted by the refresh control
    public var values: Property<Bool> {
        return propertyControlEvents(.valueChanged) { $0.isRefreshing }
    }
}

