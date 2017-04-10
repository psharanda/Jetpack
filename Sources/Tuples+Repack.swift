//
//  Created by Pavel Sharanda on 03.10.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

func repack<A, B, C>(_ t: (A, B), value: C) -> (A, B, C) {
    return (t.0, t.1, value)
}

func repack<A, B, C, D>(_ t: (A, B, C), value: D) -> (A, B, C, D) {
    return (t.0, t.1, t.2, value)
}

func repack<A, B, C, D, E>(_ t: (A, B, C, D), value: E) -> (A, B, C, D, E) {
    return (t.0, t.1, t.2, t.3, value)
}

func repack<A, B, C, D, E, F>(_ t: (A, B, C, D, E), value: F) -> (A, B, C, D, E, F) {
    return (t.0, t.1, t.2, t.3, t.4, value)
}

func repack<A, B, C>(_ t: (A?, B?)?, value: C?) -> (A?, B?, C?) {
    if let t = t {
        return (t.0, t.1, value)
    } else {
        return (nil, nil, value)
    }
}

func repack<A, B, C, D>(_ t: (A?, B?, C?)?, value: D?) -> (A?, B?, C?, D?) {
    if let t = t {
        return (t.0, t.1, t.2, value)
    } else {
        return (nil, nil, nil, value)
    }
}

func repack<A, B, C, D, E>(_ t: (A?, B?, C?, D?)?, value: E?) -> (A?, B?, C?, D?, E?) {
    if let t = t {
        return (t.0, t.1, t.2, t.3, value)
    } else {
        return (nil, nil, nil, nil, value)
    }
    
}

func repack<A, B, C, D, E, F>(_ t: (A?, B?, C?, D?, E?)?, value: F?) -> (A?, B?, C?, D?, E?, F?) {
    if let t = t {
        return (t.0, t.1, t.2, t.3, t.4, value)
    } else {
        return (nil, nil, nil, nil, nil, value)
    }
}
