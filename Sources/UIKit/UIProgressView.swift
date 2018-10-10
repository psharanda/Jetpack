import UIKit

extension JetpackExtensions where Base: UIProgressView {

	public var progress: Binder<Float> {
        return jx_makeBinder { $0.progress = $1 }
	}
}
