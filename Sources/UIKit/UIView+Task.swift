//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import UIKit

extension UIView {
    static func animationTask(withDuration duration: TimeInterval, animations: @escaping ()->Void) -> Task<Void> {
        return Task { completion in
            UIView.animate(withDuration: duration, animations: animations) { finished in
                if finished {
                    completion(.success(()))
                } else {
                    completion(.cancelled)
                }
            }
            
            return DelegateDisposable {
                animations()
            }
        }
    }
    
    static func animationTask(withDuration duration: TimeInterval, delay: TimeInterval, options: UIViewAnimationOptions, animations: @escaping ()->Void) -> Task<Void> {
        return Task { completion in
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations) { finished in
                if finished {
                    completion(.success(()))
                } else {
                    completion(.cancelled)
                }
            }
            
            return DelegateDisposable {
                animations()
            }
        }
    }

    static func animationTask(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat,  options: UIViewAnimationOptions, animations: @escaping ()->Void) -> Task<Void> {
        
        
        return Task { completion in
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations) { finished in
                if finished {
                    completion(.success(()))
                } else {
                    completion(.cancelled)
                }
            }
            
            return DelegateDisposable {
                animations()
            }
        }
    }

    static func transitionTask(with view: UIView, duration: TimeInterval, options: UIViewAnimationOptions, animations: @escaping ()->Void) -> Task<Void> {
        
        return Task { completion in
            UIView.transition(with: view, duration: duration, options: options, animations: animations) { finished in
                if finished {
                    completion(.success(()))
                } else {
                    completion(.cancelled)
                }
            }
            
            return DelegateDisposable {
                animations()
            }
        }
    }
}
