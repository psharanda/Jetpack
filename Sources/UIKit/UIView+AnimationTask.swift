//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import UIKit

enum AnimationState {
    case animating
    case cancelled
    case finished
}

extension UIView {
    static func animationTask(_ duration: TimeInterval, animations: @escaping ()->Void) -> Task<AnimationState> {
        return Task(worker: { (generator, completion) -> Cancelable? in
            generator(.animating)
            UIView.animate(withDuration: duration, delay: 0, options: [], animations: animations, completion: { (finished) in
                if finished {
                    generator(.finished)
                } else {
                    generator(.cancelled)
                }
                completion()
            })
            return nil
        })
    }
    
    static func animationTask(_ duration: TimeInterval, delay: TimeInterval, options: UIViewAnimationOptions, animations: @escaping ()->Void) -> Task<AnimationState> {
        return Task(worker: { (generator, completion) -> Cancelable? in
            generator(.animating)
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: { (finished) in
                if finished {
                    generator(.finished)
                } else {
                    generator(.cancelled)
                }
                completion()
            })
            return nil
        })
    }
    
    static func animationTask(_ duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat,  options: UIViewAnimationOptions, animations: @escaping ()->Void) -> Task<AnimationState> {
        return Task(worker: { (generator, completion) -> Cancelable? in
            generator(.animating)
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations, completion: { (finished) in
                if finished {
                    generator(.finished)
                } else {
                    generator(.cancelled)
                }
                completion()
            })
            return nil
        })
    }
    
    static func transitionTask(_ view: UIView, duration: TimeInterval, options: UIViewAnimationOptions, animations: @escaping ()->Void) -> Task<AnimationState> {
        return Task(worker: { (generator, completion) -> Cancelable? in
            generator(.animating)
            UIView.transition(with: view, duration: duration, options: options, animations: animations, completion: { (finished) in
                if finished {
                    generator(.finished)
                } else {
                    generator(.cancelled)
                }
                completion()
            })
            return nil
        })
    }
}
