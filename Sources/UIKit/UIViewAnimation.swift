import UIKit

#if swift(>=4.2)
public typealias ViewAnimationOptions = UIView.AnimationOptions
public typealias ViewKeyframeAnimationOptions = UIView.KeyframeAnimationOptions
#else
public typealias ViewAnimationOptions = UIViewAnimationOptions
public typealias ViewKeyframeAnimationOptions = UIViewKeyframeAnimationOptions
#endif

extension JetpackExtensions where Base: UIView {
    
    public static func animate(withDuration duration: TimeInterval, animations: @escaping ()->Void) -> Observable<Void> {
        return Observable { completion in
            
            var cancelled = false
            
            UIView.animate(withDuration: duration, animations: animations) { finished in
                if finished && !cancelled {
                    completion(())
                }
            }
            
            return BlockDisposable {
                cancelled = true
                animations()
            }
        }
    }
    
    public static func animate(withDuration duration: TimeInterval, delay: TimeInterval, options: ViewAnimationOptions, animations: @escaping ()->Void) -> Observable<Void> {
        return Observable { completion in
            
            var cancelled = false
            
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations) { finished in
                if finished && !cancelled {
                    completion(())
                }
            }
            
            return BlockDisposable {
                cancelled = true
                animations()
            }
        }
    }

    public static func animate(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat,  options: ViewAnimationOptions, animations: @escaping ()->Void) -> Observable<Void> {
        
        
        return Observable { completion in
            
            var cancelled = false
            
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations) { finished in
                if finished && !cancelled {
                    completion(())
                }
            }
            
            return BlockDisposable {
                cancelled = true
                animations()
            }
        }
    }
    
    public static func animateKeyframes(withDuration duration: TimeInterval, delay: TimeInterval, options: ViewKeyframeAnimationOptions, animations: @escaping ()->Void) -> Observable<Void> {
        return Observable { completion in
            
            var cancelled = false
            
            UIView.animateKeyframes(withDuration: duration, delay: delay, options: options, animations: animations) { finished in
                if finished && !cancelled {
                    completion(())
                }
            }
            
            return BlockDisposable {
                cancelled = true
                animations()
            }
        }
    }

    public static func transition(with view: UIView, duration: TimeInterval, options: ViewAnimationOptions, animations: @escaping ()->Void) -> Observable<Void> {
        
        return Observable { completion in
            
            var cancelled = false
            
            UIView.transition(with: view, duration: duration, options: options, animations: animations) { finished in
                if finished && !cancelled {
                    completion(())
                }
            }
            
            return BlockDisposable {
                cancelled = true
                animations()
            }
        }
    }
    
    public static func transition(from fromView: UIView, to toView: UIView, duration: TimeInterval, options: ViewAnimationOptions) -> Observable<Void> {
        
        return Observable { completion in
            
            var cancelled = false
            
            UIView.transition(from: fromView, to: toView, duration: duration, options: options) { finished in
                if finished && !cancelled {
                    completion(())
                }
            }
            
            return BlockDisposable {
                cancelled = true
            }
        }
    }
}
