//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

public protocol Disposable {
    func dispose()
}

extension Disposable {
    func with(disposable: Disposable) -> Disposable {
        return CompositeDisposable(left: self, right: disposable)
    }
}

public final class  EmptyDisposable: Disposable {
    
    public init() {
    }
    
    public func dispose() {}
}

public final class DelegateDisposable: Disposable {
    private var disposeImpl: (() -> Void)?
    
    public init(cancelImp: @escaping () -> Void) {
        self.disposeImpl = cancelImp
    }
    
    public func dispose() {
        disposeImpl?()
        disposeImpl = nil
    }
}

public final class CompositeDisposable: Disposable {
    private var left: Disposable?
    private var right: Disposable?
    
    public init(left: Disposable, right: Disposable) {
        self.left = left
        self.right = right
    }
    
    public func dispose() {
        left?.dispose()
        right?.dispose()
        left = nil
        right = nil
    }
}

public final class SerialDisposable: Disposable {
    private var disposable: Disposable?
    
    public init() {
    }
    
    public func swap(with: Disposable) {
        disposable = with
    }
    
    public func dispose() {
        disposable?.dispose()
        disposable = nil
    }
}

public final class SwapableDisposable: Disposable {
    private var parentDisposable: Disposable?
    private var childDisposable: Disposable?
    
    public init() {

    }
    
    public func swap(parent disposable: Disposable) {
        self.parentDisposable?.dispose()
        self.parentDisposable = disposable
    }
    
    public func swap(child disposable: Disposable) {
        self.childDisposable?.dispose()
        self.childDisposable = disposable
    }
    
    public func dispose() {
        parentDisposable?.dispose()
        parentDisposable = nil
        
        childDisposable?.dispose()
        childDisposable = nil
    }
}

public final class MultiDisposable: Disposable {
    private var disposables: [Disposable] = []
    
    public init() {
    }
    
    public func add(_ disposable: Disposable) {
        disposables.append(disposable)
    }
    
    public func dispose() {
        disposables.forEach {
            $0.dispose()
        }
        disposables.removeAll()
    }
}

public final class AutodisposePool {
    private let multi = MultiDisposable()
    
    public init() {
    }
    
    public func add(_ disposable: Disposable) {
        multi.add(disposable)
    }
    
    public func drain() {
        multi.dispose()
    }
    
    deinit {
        multi.dispose()
    }
}

extension Disposable {
    public func autodispose(in pool: AutodisposePool) {
        pool.add(self)
    }
}
