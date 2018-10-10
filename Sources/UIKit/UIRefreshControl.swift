import UIKit

extension JetpackExtensions where Base: UIRefreshControl {
	
	public var isRefreshing: Binder<Bool> {
        return jx_makeBinder { $1 ? $0.beginRefreshing() : $0.endRefreshing() }
	}

	public var attributedTitle: Binder<NSAttributedString?> {
		return jx_makeBinder { $0.attributedTitle = $1 }
	}
    
    public var isRefreshingValues: Property<Bool> {
        return propertyControlEvents(.valueChanged) { $0.isRefreshing }
    }
}

