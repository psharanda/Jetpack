import UIKit

extension JetpackExtensions where Base: UIRefreshControl {
	
	public var isRefreshing: Receiver<Bool> {
        return jx_makeReceiver { $1 ? $0.beginRefreshing() : $0.endRefreshing() }
	}

	public var attributedTitle: Receiver<NSAttributedString?> {
		return jx_makeReceiver { $0.attributedTitle = $1 }
	}
    
    public var values: Property<Bool> {
        return propertyControlEvents(.valueChanged) { $0.isRefreshing }
    }
}

