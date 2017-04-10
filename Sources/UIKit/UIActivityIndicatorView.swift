import UIKit

extension Jetpack where Base: UIActivityIndicatorView {
	
	public var isAnimating: Receiver<Bool> {
        return makeReceiver(key: #function) { $1 ? $0.startAnimating() : $0.stopAnimating() }
	}
}
