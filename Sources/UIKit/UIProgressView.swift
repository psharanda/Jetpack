#if os(iOS) || os(tvOS)

import UIKit

extension JetpackExtensions where Base: UIProgressView {

	public var progress: Consumer<Float> {
        return jx_makeConsumer { $0.progress = $1 }
	}
}

#endif
