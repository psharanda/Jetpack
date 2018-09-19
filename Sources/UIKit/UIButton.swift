import UIKit

extension JetpackExtensions where Base: UIButton {
    
    public var clicked: Observable<Void> {
        return controlEvents(.touchUpInside)
    }

	public var title: Receiver<String?> {
        return title(for: .normal)
	}

	public func title(for state: ControlState) -> Receiver<String?> {
		return jx_makeReceiver { $0.setTitle($1, for: state) }
	}
    
    public var attributedTitle: Receiver<NSAttributedString?> {
        return attributedTitle(for: .normal)
    }
    
    public func attributedTitle(for state: ControlState) -> Receiver<NSAttributedString?> {
        return jx_makeReceiver { $0.setAttributedTitle($1, for: state) }
    }
    
    public var image: Receiver<UIImage?> {
        return image(for: .normal)
    }

	public func image(for state: ControlState) -> Receiver<UIImage?> {
		return jx_makeReceiver { $0.setImage($1, for: state) }
	}
    
    public var backgroundImage: Receiver<UIImage?> {
        return backgroundImage(for: .normal)
    }
    
    public func backgroundImage(for state: ControlState) -> Receiver<UIImage?> {
        return jx_makeReceiver { $0.setBackgroundImage($1, for: state) }
    }

}
