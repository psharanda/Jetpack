//
//  Created by Pavel Sharanda on 30.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// Wrapper around some mutable array. ('set/get/subscribe')
public final class MutableArrayProperty<T>: MutableMetaProperty<[T], ArrayEditEvent> {
    
    public override init(_ value: [T] = []) {
        super.init(value)
    }
    
    public func update(at: Int, with value: T) {
        changeWithEvent {
            $0[at] = value
            return .update(at)
        }
    }

    public func remove(at: Int) {
        changeWithEvent {
            $0.remove(at: at)
            return .remove(at)
        }
    }
    
    public func append(_ newElement: T) {        
        return insert(newElement, at: value.count)
    }
    
    public func insert(_ newElement: T, at: Int) {
        changeWithEvent {
            $0.insert(newElement, at: at)
            return .insert(at)
        }
    }
    
    public func move(from: Int, to: Int) {
        changeWithEvent {
            $0.insert($0.remove(at: from), at: to)
            return .move(from, to)
        }
    }
}

/// Wrapper around some mutable 2D array (array of arrays). ('set/get/subscribe')
public final class MutableArray2DProperty<T>: MutableMetaProperty<[[T]], Array2DEditEvent> {
    
    public override init(_ value: [[T]] = []) {
        super.init(value)
    }
    
    public func updateSection(at: Int, with value: [T]) {
        changeWithEvent {
            $0[at] = value
            return .updateSection(at)
        }
    }
    
    public func removeSection(at: Int) {
        changeWithEvent {
            $0.remove(at: at)
            return .removeSection(at)
        }
    }
    
    public func insertSection(_ newElement: [T], at: Int) {
        changeWithEvent {
            $0.insert(newElement, at: at)
            return .insertSection(at)
        }
    }
    
    public func moveSection(from: Int, to: Int) {
        changeWithEvent {
            $0.insert($0.remove(at: from), at: to)
            return .moveSection(from, to)
        }
    }
    
    public func updateItem(at: IndexPath, with value: T) {
        changeWithEvent {
            $0[at.section][at.item] = value
            return .updateItem(at)
        }
    }
    
    public func removeItem(at: IndexPath) {
        changeWithEvent {
            $0[at.section].remove(at: at.item)
            return .removeItem(at)
        }
    }
    
    public func insertItem(_ newElement: T, at: IndexPath) {
        changeWithEvent {
            $0[at.section].insert(newElement, at: at.item)
            return .insertItem(at)
        }
    }
    
    public func moveItem(from: IndexPath, to: IndexPath) {
        changeWithEvent {
            $0[to.section].insert($0[from.section].remove(at: from.item), at: to.item)
            return .moveItem(from, to)
        }
    }
}
