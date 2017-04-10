//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation


extension Disposable {
    func with(disposable: Disposable) -> Disposable {
        return CompositeDisposable(left: self, right: disposable)
    }
}

final class  EmptyDisposable: Disposable {
    func dispose() {}
}

final class DelegateDisposable: Disposable {
    private var disposeImpl: (() -> Void)?
    
    init(cancelImp: @escaping () -> Void) {
        self.disposeImpl = cancelImp
    }
    
    func dispose() {
        disposeImpl?()
        disposeImpl = nil
    }
}

final class CompositeDisposable: Disposable {
    private var left: Disposable?
    private var right: Disposable?
    
    init(left: Disposable, right: Disposable) {
        self.left = left
        self.right = right
    }
    
    func dispose() {
        left?.dispose()
        right?.dispose()
        left = nil
        right = nil
    }
}

final class SerialDisposable: Disposable {
    private var disposable: Disposable?
    
    func swap(with: Disposable) {
        disposable = with
    }
    
    func dispose() {
        disposable?.dispose()
        disposable = nil
    }
}

final class MultiDisposable: Disposable {
    private var disposables: [Disposable] = []
    
    func add(_ disposable: Disposable) {
        disposables.append(disposable)
    }
    
    func dispose() {
        disposables.forEach {
            $0.dispose()
        }
        disposables.removeAll()
    }
}
