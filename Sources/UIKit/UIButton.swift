import UIKit

extension JetpackExtensions where Base: UIButton {
    
    public var clicked: Observer<Void> {
        return signalControlEvents(.touchUpInside) {_ in }
    }

	public var title: Receiver<String?> {
        return title(for: .normal)
	}

	public func title(for state: UIControlState) -> Receiver<String?> {
		return jx_makeReceiver(key: "\(#function) \(state.rawValue)") { $0.setTitle($1, for: state) }
	}
    
    public var attributedTitle: Receiver<NSAttributedString?> {
        return attributedTitle(for: .normal)
    }
    
    public func attributedTitle(for state: UIControlState) -> Receiver<NSAttributedString?> {
        return jx_makeReceiver(key: "\(#function) \(state.rawValue)") { $0.setAttributedTitle($1, for: state) }
    }
    
    public var image: Receiver<UIImage?> {
        return image(for: .normal)
    }

	public func image(for state: UIControlState) -> Receiver<UIImage?> {
		return jx_makeReceiver(key: "\(#function) (\(state.rawValue)") { $0.setImage($1, for: state) }
	}
    
    public var backgroundImage: Receiver<UIImage?> {
        return backgroundImage(for: .normal)
    }
    
    public func backgroundImage(for state: UIControlState) -> Receiver<UIImage?> {
        return jx_makeReceiver(key: "\(#function) \(state.rawValue)") { $0.setBackgroundImage($1, for: state) }
    }

}
