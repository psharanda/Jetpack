import UIKit

extension JetpackExtensions where Base: UIActivityIndicatorView {
	
	public var isAnimating: Consumer<Bool> {
        return jx_makeConsumer { $1 ? $0.startAnimating() : $0.stopAnimating() }
	}
}
