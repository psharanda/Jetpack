import UIKit

extension Jetpack where Base: UIButton {
    
    /// Sets the title of the button for its normal state.
    public var clicked: Observable<Void> {
        return signalControlEvents(.touchUpInside) {_ in
            ()
        }
    }

	/// Sets the title of the button for its normal state.
	public var title: BindingTarget<String?> {
        return title(for: .normal)
	}

	/// Sets the title of the button for the specified state.
	public func title(for state: UIControlState) -> BindingTarget<String?> {
		return makeBindingTarget(key: "title \(state.rawValue)") { $0.setTitle($1, for: state) }
	}
    
    /// Sets the title of the button for its normal state.
    public var attributedTitle: BindingTarget<NSAttributedString?> {
        return attributedTitle(for: .normal)
    }
    
    /// Sets the title of the button for the specified state.
    public func attributedTitle(for state: UIControlState) -> BindingTarget<NSAttributedString?> {
        return makeBindingTarget(key: "attributedTitle \(state.rawValue)") { $0.setAttributedTitle($1, for: state) }
    }
    
    public var image: BindingTarget<UIImage?> {
        return image(for: .normal)
    }

	/// Sets the image of the button for the specified state.
	public func image(for state: UIControlState) -> BindingTarget<UIImage?> {
		return makeBindingTarget(key: "image (\(state.rawValue)") { $0.setImage($1, for: state) }
	}
    
    public var backgroundImage: BindingTarget<UIImage?> {
        return backgroundImage(for: .normal)
    }
    
    /// Sets the background image of the button for the specified state.
    public func backgroundImage(for state: UIControlState) -> BindingTarget<UIImage?> {
        return makeBindingTarget(key: "backgroundImage \(state.rawValue)") { $0.setBackgroundImage($1, for: state) }
    }

}
