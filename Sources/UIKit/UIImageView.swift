import UIKit

extension JetpackExtensions where Base: UIImageView {

	public var image: Receiver<UIImage?> {
        return jx_makeReceiver(key: #function) { $0.image = $1 }
	}
    
	public var highlightedImage: Receiver<UIImage?> {
		return jx_makeReceiver(key: #function) { $0.highlightedImage = $1 }
	}
}
