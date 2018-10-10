import UIKit

extension JetpackExtensions where Base: UIImageView {

	public var image: Binder<UIImage?> {
        return jx_makeBinder { $0.image = $1 }
	}
    
	public var highlightedImage: Binder<UIImage?> {
		return jx_makeBinder { $0.highlightedImage = $1 }
	}
}
