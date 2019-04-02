#if os(iOS) || os(tvOS)

import Foundation
import QuartzCore

extension JetpackExtensions where Base: CADisplayLink {    
    public static func repeated(timeInterval: TimeInterval = TimeInterval.greatestFiniteMagnitude, skipFrames: Int = 0) -> Observable<Double> {
        return Observable { generator in
            return DisplayLinkDisposable(displayLinkTask: DisplayLinkTask(timeInterval: timeInterval, skipFrames: skipFrames, generator: generator))
        }
    }
}

private class DisplayLinkDisposable: Disposable {
    
    private weak var displayLinkTask: DisplayLinkTask?
    init(displayLinkTask: DisplayLinkTask) {
        self.displayLinkTask = displayLinkTask
    }
    func dispose() {
        displayLinkTask?.stopDisplayLink()
        displayLinkTask = nil
    }
}

private class DisplayLinkTask {
    private let timeInterval: TimeInterval
    private var displayLink : CADisplayLink?
    private let startTime: CFTimeInterval
    private let generator: (Double)->Void
    
    private let skipFrames: Int
    private var skippedFrames: Int = 0
    
    init(timeInterval: TimeInterval, skipFrames: Int, generator: @escaping (Double)->Void) {
        self.timeInterval = timeInterval
        self.generator = generator
        self.skipFrames = skipFrames
        startTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
        #if swift(>=4.2)
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        #else
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        #endif
    }
    
    @objc private func displayLinkDidFire() {
        
        let elapsed = CACurrentMediaTime() - startTime
        
        if elapsed > timeInterval {
            stopDisplayLink()
            generator(1)
        } else {
            if skippedFrames == 0 {
                generator(elapsed/timeInterval)
            }
            skippedFrames += 1
        }
        if skippedFrames > skipFrames {
            skippedFrames = 0
        }
    }
    
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

#endif
