import UIKit

extension JetpackExtensions where Base: UIView {
    
    public var backgroundColor: Receiver<UIColor?> {
        return jx_makeReceiver { $0.backgroundColor = $1 }
    }
    
	public var alpha: Receiver<CGFloat> {
        return jx_makeReceiver { $0.alpha = $1 }
	}

	public var isHidden: Receiver<Bool> {
		return jx_makeReceiver { $0.isHidden = $1 }
	}

	public var isUserInteractionEnabled: Receiver<Bool> {
		return jx_makeReceiver { $0.isUserInteractionEnabled = $1 }
	}
}
