//
//  ArrayProperty.swift
//  Jetpack
//
//  Created by Pavel Sharanda on 30.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

public enum ArrayEditEvent: ChangeEventProtocol {
    case set
    case remove(Int)
    case insert(Int)
    case move(Int, Int)
    case update(Int)
    
    public static var resetEvent: ArrayEditEvent {
        return .set
    }
}

public typealias ArrayProperty<T> = MetaProperty<[T], ArrayEditEvent>

public enum Array2DEditEvent: ChangeEventProtocol {
    case set
    case removeItem(IndexPath)
    case insertItem(IndexPath)
    case moveItem(IndexPath, IndexPath)
    case updateItem(IndexPath)
    
    case removeSection(Int)
    case insertSection(Int)
    case moveSection(Int, Int)
    case updateSection(Int)
    
    public static var resetEvent: Array2DEditEvent {
        return .set
    }
}

public typealias Array2DProperty<T> = MetaProperty<[[T]], Array2DEditEvent>



