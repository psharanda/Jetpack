//
//  Created by Pavel Sharanda on 06.04.17.
//  Copyright © 2017 Task. All rights reserved.
//

import Foundation

extension JetpackExtensions where Base: DispatchQueue {

    @discardableResult
    public func asyncAfter(deadline: DispatchTime, execute work: @escaping ()->Void) ->  Disposable {
        let item = DispatchWorkItem(block: work)
        base.asyncAfter(deadline: deadline, execute: item)
        return BlockDisposable { item.cancel() }
    }
    
    @discardableResult
    public func async(execute work: @escaping ()->Void) ->  Disposable {
        let item = DispatchWorkItem(block: work)
        base.async(execute: item)
        return BlockDisposable { item.cancel() }
    }
}

