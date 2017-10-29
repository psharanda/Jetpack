//
//  Created by Pavel Sharanda on 17.05.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension JetpackExtensions where Base: Timer {
    public static func repeated(timeInterval: TimeInterval) -> Observable<Void> {
        return Observable<Void> { observer in
            let timerOwner = TimerOwner(observer: observer)
            let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: timerOwner, selector: #selector(TimerOwner.handleTimer), userInfo: nil, repeats: true)
            return TimerDisposable(timer: timer)
        }
    }
}

private class TimerOwner: NSObject {
    let observer: ()->Void
    init(observer: @escaping ()->Void) {
        self.observer = observer
    }
    
    @objc func handleTimer() {
        observer()
    }
}

private class TimerDisposable: Disposable {
    private weak var timer: Timer?
    
    init(timer: Timer) {
        self.timer = timer
    }
    
    func dispose() {
        timer?.invalidate()
        timer = nil
    }
}
