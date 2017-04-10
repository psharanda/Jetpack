import UIKit


extension Jetpack where Base: UIGestureRecognizer {
    
    public var stateChanged: Observable<(CGPoint, UIGestureRecognizerState)> {
        return makeObservable(key: "stateChanged", setup: { base, target, action, _ in
            base.addTarget(target, action: action)
        }) { base in
            (base.location(in: base.view), base.state)
        }
    }
}
