#if os(iOS) || os(tvOS)

import UIKit

extension JetpackExtensions where Base: UIView {
    
    public var backgroundColor: Consumer<UIColor?> {
        return jx_makeConsumer { $0.backgroundColor = $1 }
    }
    
	public var alpha: Consumer<CGFloat> {
        return jx_makeConsumer { $0.alpha = $1 }
	}

	public var isHidden: Consumer<Bool> {
		return jx_makeConsumer { $0.isHidden = $1 }
	}

	public var isUserInteractionEnabled: Consumer<Bool> {
		return jx_makeConsumer { $0.isUserInteractionEnabled = $1 }
	}
}

#endif
