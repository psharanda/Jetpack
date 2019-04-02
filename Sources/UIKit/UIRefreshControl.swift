#if os(iOS)

import UIKit

extension JetpackExtensions where Base: UIRefreshControl {
	
	public var isRefreshing: Consumer<Bool> {
        return jx_makeConsumer { $1 ? $0.beginRefreshing() : $0.endRefreshing() }
	}

	public var attributedTitle: Consumer<NSAttributedString?> {
		return jx_makeConsumer { $0.attributedTitle = $1 }
	}
    
    public var isRefreshingValues: Property<Bool> {
        return propertyControlEvents(.valueChanged) { $0.isRefreshing }
    }
}

#endif
