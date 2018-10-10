import UIKit

extension JetpackExtensions where Base: UIBarItem {
	
	public var isEnabled: Binder<Bool> {
		return jx_makeBinder { $0.isEnabled = $1 }
	}

	public var image: Binder<UIImage?> {
        return jx_makeBinder { $0.image = $1 }
	}

	public var title: Binder<String?> {
		return jx_makeBinder { $0.title = $1 }
	}
}
