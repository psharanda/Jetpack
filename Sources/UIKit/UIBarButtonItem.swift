#if os(iOS) || os(tvOS)

import UIKit

extension JetpackExtensions where Base: UIBarButtonItem {
    
    public var clicked: Observable<Void> {
        return jx_makeTargetActionSubject(key: #function, setup: { base, target, action in
            base.target = target
            base.action = action
        }, cleanup: { base, _, _ in
            base.target = nil
            base.action = nil
        }, getter: { _ in
            ()
        }).asObservable
    }
}

extension UIBarButtonItem {
    
    public convenience init(title: String?) {
        self.init(title: title, style: .plain, target: nil, action: nil)
    }
    
    public convenience init(image: UIImage?) {
        self.init(image: image, style: .plain, target: nil, action: nil)
    }
    
    #if swift(>=4.2)
    public convenience init(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
    }
    #else
    public convenience init(barButtonSystemItem systemItem: UIBarButtonSystemItem) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
    }
    #endif
    
}

#endif
