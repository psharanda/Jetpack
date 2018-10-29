//
//  Created by Pavel Sharanda on 20.03.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation


extension ObservableProtocol {
    
    public func flatMapLatest<U>(_ f: @escaping ((ValueType) -> Observable<U>)) -> Observable<U> {
        return Observable { observer in
            let parent = SwapableDisposable()
            let child = SwapableDisposable()
            parent.swap(with: self.subscribe { result in
                child.swap(with: f(result).subscribe(observer))
            })
            return parent.with(disposable: child)
        }
    }
    
    public func flatMapMerge<U>(_ f: @escaping ((ValueType) -> Observable<U>)) -> Observable<U> {
        return Observable { observer in
            let multi = CompositeDisposable()
            
            multi.add(self.subscribe { result in
                multi.add(f(result).subscribe(observer))
            })
            return multi
        }
    }
}

