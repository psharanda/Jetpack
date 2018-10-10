import UIKit

extension JetpackExtensions where Base: UIView {
    
    public var backgroundColor: Binder<UIColor?> {
        return jx_makeBinder { $0.backgroundColor = $1 }
    }
    
	public var alpha: Binder<CGFloat> {
        return jx_makeBinder { $0.alpha = $1 }
	}

	public var isHidden: Binder<Bool> {
		return jx_makeBinder { $0.isHidden = $1 }
	}

	public var isUserInteractionEnabled: Binder<Bool> {
		return jx_makeBinder { $0.isUserInteractionEnabled = $1 }
	}
}
