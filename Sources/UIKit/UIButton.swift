#if os(iOS) || os(tvOS)

import UIKit

extension JetpackExtensions where Base: UIButton {
    
    public var clicked: Observable<Void> {
        return controlEvents(.touchUpInside)
    }

	public var title: Consumer<String?> {
        return title(for: .normal)
	}

	public func title(for state: ControlState) -> Consumer<String?> {
		return jx_makeConsumer { $0.setTitle($1, for: state) }
	}
    
    public var attributedTitle: Consumer<NSAttributedString?> {
        return attributedTitle(for: .normal)
    }
    
    public func attributedTitle(for state: ControlState) -> Consumer<NSAttributedString?> {
        return jx_makeConsumer { $0.setAttributedTitle($1, for: state) }
    }
    
    public var image: Consumer<UIImage?> {
        return image(for: .normal)
    }

	public func image(for state: ControlState) -> Consumer<UIImage?> {
		return jx_makeConsumer { $0.setImage($1, for: state) }
	}
    
    public var backgroundImage: Consumer<UIImage?> {
        return backgroundImage(for: .normal)
    }
    
    public func backgroundImage(for state: ControlState) -> Consumer<UIImage?> {
        return jx_makeConsumer { $0.setBackgroundImage($1, for: state) }
    }

}

#endif
