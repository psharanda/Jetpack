import UIKit


extension JetpackExtensions where Base: UIGestureRecognizer {
    
    public var stateChanged: Observable<(Base)> {
        return jx_makeTargetActionObservable(setup: { base, target, action in
            base.addTarget(target, action: action)
        }, cleanup: { base, target, action in
            base.removeTarget(target, action: action)
        }, getter: { base in
            return base
        })
    }
}
