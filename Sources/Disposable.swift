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
        let c = CompositeDisposable()
        c.add(disposable)
        c.add(self)
        return c
    }
}

public final class  EmptyDisposable: Disposable {
    
    public init() {}
    
    public func dispose() {}
}

public final class BlockDisposable: Disposable {
    private var block: (() -> Void)?
    
    public init(block: @escaping () -> Void) {
        self.block = block
    }
    
    public func dispose() {
        block?()
        block = nil
    }
}

public final class SwapableDisposable: Disposable {
    private var disposable: Disposable?
    
    public init() { }
    
    public func swap(with disposable: Disposable) {
        dispose()
        self.disposable = disposable
    }
    public func dispose() {
        disposable?.dispose()
        disposable = nil
    }
}

public final class CompositeDisposable: Disposable {
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

public final class DisposeBag {
    private let multi = CompositeDisposable()
    
    public init() { }
    
    public func add(_ disposable: Disposable) {
        multi.add(disposable)
    }
    
    public func dispose() {
        multi.dispose()
    }
    
    deinit {
        dispose()
    }
}


extension Disposable {
    public func disposed(by bag: DisposeBag) {
        bag.add(self)
    }
}
