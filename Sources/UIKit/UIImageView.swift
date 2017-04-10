import UIKit

extension Jetpack where Base: UIImageView {

	public var image: Receiver<UIImage?> {
        return makeReceiver(key: #function) { $0.image = $1 }
	}
    
	public var highlightedImage: Receiver<UIImage?> {
		return makeReceiver(key: #function) { $0.highlightedImage = $1 }
	}
}
