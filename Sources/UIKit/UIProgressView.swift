import UIKit

extension Jetpack where Base: UIProgressView {

	public var progress: Receiver<Float> {
        return makeReceiver(key: #function) { $0.progress = $1 }
	}
}
