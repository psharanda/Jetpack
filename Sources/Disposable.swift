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
    
    public init() {}
    
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

public final class SwapableDisposable: Disposable {
    private var parentDisposable: Disposable?
    private var childDisposable: Disposable?
    
    public init() {

    }
    
    public func disposeParent() {
        parentDisposable?.dispose()
        parentDisposable = nil
    }
    
    public func swap(parent disposable: Disposable) {
        self.parentDisposable = disposable
    }
    
    public func disposeChild() {
        childDisposable?.dispose()
        childDisposable = nil
    }
    
    public func swap(child disposable: Disposable?) {
        self.childDisposable = disposable
    }
    
    public func dispose() {
        disposeParent()
        disposeChild()
    }
}

public final class MultiDisposable: Disposable {
    private var disposables: [Disposable] = []
    
    public init() {
    }
    
    public func add(_ disposable: Disposable?) {
        if let d = disposable {
            disposables.append(d)
        }
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
    
    public init() { }
    
    public func add(_ disposable: Disposable) {
        multi.add(disposable)
    }
    
    public func drain() {
        multi.dispose()
    }
    
    deinit {
        drain()
    }
}

public final class AutodisposeBox {
    
    private var disposable: Disposable?
    
    public init() { }
    
    public func put(_ disposable: Disposable) {
        drain()
        self.disposable = disposable
    }
    
    public func drain() {
        disposable?.dispose()
        disposable = nil
    }
    
    deinit {
        drain()
    }
}

extension Disposable {
    public func autodispose(in pool: AutodisposePool) {
        pool.add(self)
    }
    
    public func autodispose(in box: AutodisposeBox) {
        box.put(self)
    }
}
