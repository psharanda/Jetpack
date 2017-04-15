import UIKit

extension JetpackExtensions where Base: UIBarItem {
	
	public var isEnabled: Receiver<Bool> {
		return makeReceiver(key: #function) { $0.isEnabled = $1 }
	}

	public var image: Receiver<UIImage?> {
        return makeReceiver(key: #function) { $0.image = $1 }
	}

	public var title: Receiver<String?> {
		return makeReceiver(key: #function) { $0.title = $1 }
	}
}
