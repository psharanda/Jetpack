import Foundation
import QuartzCore

extension JetpackExtensions where Base: CADisplayLink {    
    public static func repeated(timeInterval: TimeInterval = TimeInterval.greatestFiniteMagnitude, skipFrames: Int = 0) -> Observer<Double> {
        return Observer<Double> { generator in
            return DisplayLinkDisposable(interpolator: DisplayLinkTask(timeInterval: timeInterval, skipFrames: skipFrames, generator: generator))
        }
    }
}

private class DisplayLinkDisposable: Disposable {
    
    weak var interpolator: DisplayLinkTask?
    init(interpolator: DisplayLinkTask) {
        self.interpolator = interpolator
    }
    func dispose() {
        interpolator?.stopDisplayLink()
        interpolator = nil
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
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        
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

