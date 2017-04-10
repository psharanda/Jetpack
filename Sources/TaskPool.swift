//
//  Created by Pavel Sharanda on 25.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation


//special object which can be used for life time control of task starter signals
public class TaskPool {
    private var tasks: [Cancelable] = []
    
    public init() {
        
    }
    
    public func runTask<T>(_ task: Task<T>) {
        
        tasks.append(task)
        
        task.completion.subscribe {[weak self, weak task] _ in
            guard let sself = self else { return }
            guard let task = task else { return }
            sself.tasks = sself.tasks.filter {
                $0 !== task
            }
        }
    }
}

