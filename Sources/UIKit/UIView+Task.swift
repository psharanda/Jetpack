import UIKit

extension UIView {
    public static func animationTask(withDuration duration: TimeInterval, animations: @escaping ()->Void) -> Observer<Void> {
        return Observer { completion in
            UIView.animate(withDuration: duration, animations: animations) { finished in
                if finished {
                    completion()
                }
            }
            
            return DelegateDisposable {
                animations()
            }
        }
    }
    
    public static func animationTask(withDuration duration: TimeInterval, delay: TimeInterval, options: UIViewAnimationOptions, animations: @escaping ()->Void) -> Observer<Void> {
        return Observer { completion in
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations) { finished in
                if finished {
                    completion()
                }
            }
            
            return DelegateDisposable {
                animations()
            }
        }
    }

    public static func animationTask(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat,  options: UIViewAnimationOptions, animations: @escaping ()->Void) -> Observer<Void> {
        
        
        return Observer { completion in
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations) { finished in
                if finished {
                    completion()
                }
            }
            
            return DelegateDisposable {
                animations()
            }
        }
    }

    public static func transitionTask(with view: UIView, duration: TimeInterval, options: UIViewAnimationOptions, animations: @escaping ()->Void) -> Observer<Void> {
        
        return Observer { completion in
            UIView.transition(with: view, duration: duration, options: options, animations: animations) { finished in
                if finished {
                    completion()
                }
            }
            
            return DelegateDisposable {
                animations()
            }
        }
    }
}
