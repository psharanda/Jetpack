import UIKit


extension JetpackExtensions where Base: UIGestureRecognizer {
    
    public var stateChanged: Observer<(CGPoint, UIGestureRecognizerState)> {        
        return jx_makeTargetActionObserver(key: #function, setup: { base, target, action in
            base.addTarget(target, action: action)
        }, cleanup: { base, target, action in
            base.removeTarget(target, action: action)
        }, getter: { base in
            (base.location(in: base.view), base.state)
        })        
    }
}
