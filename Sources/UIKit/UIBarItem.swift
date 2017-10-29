import UIKit

extension JetpackExtensions where Base: UIBarItem {
	
	public var isEnabled: Receiver<Bool> {
		return jx_makeReceiver { $0.isEnabled = $1 }
	}

	public var image: Receiver<UIImage?> {
        return jx_makeReceiver { $0.image = $1 }
	}

	public var title: Receiver<String?> {
		return jx_makeReceiver { $0.title = $1 }
	}
}
