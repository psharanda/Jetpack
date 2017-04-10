import UIKit

extension Jetpack where Base: UIRefreshControl {
	
	public var isRefreshing: Receiver<Bool> {
        return makeReceiver(key: #function) { $1 ? $0.beginRefreshing() : $0.endRefreshing() }
	}

	public var attributedTitle: Receiver<NSAttributedString?> {
		return makeReceiver(key: #function) { $0.attributedTitle = $1 }
	}
    
    public var values: Property<Bool> {
        return propertyControlEvents(.valueChanged) { $0.isRefreshing }
    }
}

