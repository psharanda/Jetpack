import UIKit

extension JetpackExtensions where Base: UIActivityIndicatorView {
	
	public var isAnimating: Receiver<Bool> {
        return jx_makeReceiver { $1 ? $0.startAnimating() : $0.stopAnimating() }
	}
}
