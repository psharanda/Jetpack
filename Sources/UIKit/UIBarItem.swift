#if os(iOS) || os(tvOS)

import UIKit

extension JetpackExtensions where Base: UIBarItem {
	
	public var isEnabled: Consumer<Bool> {
		return jx_makeConsumer { $0.isEnabled = $1 }
	}

	public var image: Consumer<UIImage?> {
        return jx_makeConsumer { $0.image = $1 }
	}

	public var title: Consumer<String?> {
		return jx_makeConsumer { $0.title = $1 }
	}
}

#endif


