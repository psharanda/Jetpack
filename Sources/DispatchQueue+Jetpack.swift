//
//  Created by Pavel Sharanda on 06.04.17.
//  Copyright © 2017 Task. All rights reserved.
//

import Foundation

extension DispatchQueue {

    func jx_asyncAfter(deadline: DispatchTime, execute work: @escaping () -> Void) -> Disposable {
        let item = DispatchWorkItem(block: work)
        asyncAfter(deadline: deadline, execute: item)
        return BlockDisposable { item.cancel() }
    }
    
    func jx_async(execute work: @escaping () -> Void) -> Disposable {
        let item = DispatchWorkItem(block: work)
        async(execute: item)
        return BlockDisposable { item.cancel() }
    }
}

