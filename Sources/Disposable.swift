//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

public protocol Disposable {
    func dispose()
}

public final class  EmptyDisposable: Disposable {
    
    public init() {}
    
    public func dispose() {}
}

public final class BlockDisposable: Disposable {
    private var block: (() -> Void)?
    private let lock = Lock()
    
    public init(block: @escaping () -> Void) {
        self.block = block
    }
    
    public func dispose() {
        lock.synchronized {
            block?()
            block = nil
        }
    }
}


public final class SwapableDisposable: Disposable {
    private var disposable: Disposable?
    private let lock = Lock()
    
    public init() { }
    
    public func swap(with other: Disposable?) {
        lock.synchronized {
            disposable?.dispose()
            disposable = other
        }
    }
    
    public func dispose() {
        swap(with: nil)
    }
}

public final class CompositeDisposable: Disposable {
    private var disposables = [Disposable]()
    private let lock = Lock()
    
    public init() { }
    
    public func add(_ disposable: Disposable) {
        lock.synchronized {
            disposables.append(disposable)
        }
    }
    
    public func dispose() {
        lock.synchronized {
            disposables.forEach {
                $0.dispose()
            }
            disposables.removeAll()
        }
    }
}

public final class ScopedDisposable: Disposable {
    
    private let disposable: Disposable
    
    public init(disposable: Disposable) {
        self.disposable = disposable
    }
    
    public func dispose() {
        disposable.dispose()
    }
    
    deinit {
        disposable.dispose()
    }
}

public final class DisposeBag {
    private let multi = CompositeDisposable()
    
    public init() { }
    
    public func add(_ disposable: Disposable) {
        multi.add(disposable)
    }
    
    deinit {
        multi.dispose()
    }
}


extension Disposable {
    
    public func disposed(by bag: DisposeBag) {
        bag.add(self)
    }
    
    public func with(disposable: Disposable) -> Disposable {
        let c = CompositeDisposable()
        c.add(disposable)
        c.add(self)
        return c
    }
    
    public func scoped() -> Disposable {
        return ScopedDisposable(disposable: self)
    }
    
    func locked(with lock: Lock) -> Disposable {
        return BlockDisposable {
            lock.synchronized {
                self.dispose()
            }
        }
    }
}
