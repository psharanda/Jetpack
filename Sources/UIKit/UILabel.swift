import UIKit

extension JetpackExtensions where Base: UILabel {
	
	public var text: Binder<String?> {
		return jx_makeBinder { $0.text = $1 }
	}

	public var attributedText: Binder<NSAttributedString?> {
        return jx_makeBinder { $0.attributedText = $1 }
	}
}
