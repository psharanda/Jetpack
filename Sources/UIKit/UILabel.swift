import UIKit

extension JetpackExtensions where Base: UILabel {
	
	public var text: Consumer<String?> {
		return jx_makeConsumer { $0.text = $1 }
	}

	public var attributedText: Consumer<NSAttributedString?> {
        return jx_makeConsumer { $0.attributedText = $1 }
	}
}
