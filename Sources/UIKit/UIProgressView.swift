import UIKit

extension JetpackExtensions where Base: UIProgressView {

	public var progress: Receiver<Float> {
        return jx_makeReceiver(key: #function) { $0.progress = $1 }
	}
}
