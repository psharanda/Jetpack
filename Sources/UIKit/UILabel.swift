import UIKit

extension JetpackExtensions where Base: UILabel {
	
	public var text: Receiver<String?> {
		return jx_makeReceiver { $0.text = $1 }
	}

	public var attributedText: Receiver<NSAttributedString?> {
        return jx_makeReceiver { $0.attributedText = $1 }
	}
}
