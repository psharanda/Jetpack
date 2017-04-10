import UIKit

extension Jetpack where Base: UIBarButtonItem {
    
    public var clicked: Observable<Void> {
        return makeObservable(key: "clicked", setup: { base, target, action, _ in
            base.target = target
            base.action = action
        }) { _ in
            ()
        }
    }
}


extension UIBarButtonItem {
    
    public convenience init(title: String) {
        self.init(title: title, style: .plain, target: nil, action: nil)
    }
    
    public convenience init(image: UIImage) {
        self.init(image: image, style: .plain, target: nil, action: nil)
    }
    
    public convenience init(barButtonSystemItem systemItem: UIBarButtonSystemItem) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
    }
}

