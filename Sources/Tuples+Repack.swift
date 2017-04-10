//
//  Created by Pavel Sharanda on 03.10.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
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

func repack<A, B, C, D, E, F, G>(_ t: (A, B, C, D, E, F), value: G) -> (A, B, C, D, E, F, G) {
    return (t.0, t.1, t.2, t.3, t.4, t.5, value)
}

func repack<A, B, C, D, E, F, G, H>(_ t: (A, B, C, D, E, F, G), value: H) -> (A, B, C, D, E, F, G, H) {
    return (t.0, t.1, t.2, t.3, t.4, t.5, t.6, value)
}

func repack<A, B, C, D, E, F, G, H, I>(_ t: (A, B, C, D, E, F, G, H), value: I) -> (A, B, C, D, E, F, G, H, I) {
    return (t.0, t.1, t.2, t.3, t.4, t.5, t.6, t.7, value)
}

func repack<A, B, C, D, E, F, G, H, I, J>(_ t: (A, B, C, D, E, F, G, H, I), value: J) -> (A, B, C, D, E, F, G, H, I, J) {
    return (t.0, t.1, t.2, t.3, t.4, t.5, t.6, t.7, t.8, value)
}
