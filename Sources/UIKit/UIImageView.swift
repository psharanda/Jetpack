#if os(iOS) || os(tvOS)

import UIKit

extension JetpackExtensions where Base: UIImageView {

	public var image: Consumer<UIImage?> {
        return jx_makeConsumer { $0.image = $1 }
	}
    
	public var highlightedImage: Consumer<UIImage?> {
		return jx_makeConsumer { $0.highlightedImage = $1 }
	}
}

#endif
