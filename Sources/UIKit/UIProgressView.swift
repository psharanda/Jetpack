import UIKit

extension JetpackExtensions where Base: UIProgressView {

	public var progress: Receiver<Float> {
        return jx_makeReceiver { $0.progress = $1 }
	}
}
