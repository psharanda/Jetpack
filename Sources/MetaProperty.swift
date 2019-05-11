//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

public protocol ChangeEventProtocol {
    static var resetEvent: Self {get}
}

public final class MetaProperty<T, Event: ChangeEventProtocol>: ObservableProtocol, GetValueProtocol {
    private let property: Property<(T, Event)>
    
    public var value: T {
        return property.value.0
    }
    
    init(property: Property<(T, Event)>) {
        self.property = property
    }

    @discardableResult
    public func subscribe(_ observer: @escaping ((T, Event)) -> Void) -> Disposable {
        return property.subscribe(observer)
    }
    
    public var asProperty: Property<T> {
        return property.map { $0.0 }
    }
}

extension MetaProperty {
    public static func just(_ value: T) -> MetaProperty<T, Event> {
        return MetaProperty(property: Property.just((value, Event.resetEvent)))
    }
}
