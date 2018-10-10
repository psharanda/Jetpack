import UIKit

extension JetpackExtensions where Base: UIButton {
    
    public var clicked: Observable<Void> {
        return controlEvents(.touchUpInside)
    }

	public var title: Binder<String?> {
        return title(for: .normal)
	}

	public func title(for state: ControlState) -> Binder<String?> {
		return jx_makeBinder { $0.setTitle($1, for: state) }
	}
    
    public var attributedTitle: Binder<NSAttributedString?> {
        return attributedTitle(for: .normal)
    }
    
    public func attributedTitle(for state: ControlState) -> Binder<NSAttributedString?> {
        return jx_makeBinder { $0.setAttributedTitle($1, for: state) }
    }
    
    public var image: Binder<UIImage?> {
        return image(for: .normal)
    }

	public func image(for state: ControlState) -> Binder<UIImage?> {
		return jx_makeBinder { $0.setImage($1, for: state) }
	}
    
    public var backgroundImage: Binder<UIImage?> {
        return backgroundImage(for: .normal)
    }
    
    public func backgroundImage(for state: ControlState) -> Binder<UIImage?> {
        return jx_makeBinder { $0.setBackgroundImage($1, for: state) }
    }

}
