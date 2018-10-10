import UIKit

extension JetpackExtensions where Base: UIActivityIndicatorView {
	
	public var isAnimating: Binder<Bool> {
        return jx_makeBinder { $1 ? $0.startAnimating() : $0.stopAnimating() }
	}
}
