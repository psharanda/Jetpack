//
//  JetpackTests.swift
//  Jetpack
//
//  Created by Pavel Sharanda on {TODAY}.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import Jetpack

class JetpackTests: XCTestCase {
    
    func testFromValueObservable() {
        
        let value = 10
        let o = Observer.from(value: value)
        
        var fired = false
        
        o.subscribe {
            fired = true
            XCTAssertEqual(value, $0)
        }
        
        XCTAssertEqual(fired, true)
    }
    
    func testObservable() {
        
        class Button {
            
            deinit {
                
            }
            
            var click = Signal<Void>()
            
            func performClick() {
                click.update()
            }
        }
        
        let button = Button()
        
        var fired = false
        
        let d = button.click.subscribe {
            fired = !fired
        }
        
        button.performClick()
        
        XCTAssertEqual(fired, true)
        
        d.dispose()
        
        
        XCTAssertEqual(fired, true)
        
        _ = button.click.map { _ in "hello" }.map { $0.uppercased() }.subscribe {
            XCTAssertEqual($0, "HELLO")
        }
        
        button.performClick()
    }
    
    func testState() {
        
        class Test {
            private let state = State(0)
            var stateProperty: Property<Int> {
                return state.asProperty
            }
            
            var receiver: Receiver<Int> {
                return state.asReceiver
            }
        }
        
        
        let t = Test()
        
        var fired = false
        var value = 0
        
        t.stateProperty.map { $0 * 10 }.subscribe {
            fired = true
            XCTAssertEqual(value, $0)
        }
        
        value = 100
        t.receiver.update(value/10)
        
        XCTAssertEqual(fired, true)
    }
    
    func testFiredTimes() {
        
        let state = State("Hello")
        
        var observable = Optional.some(state.map { $0.uppercased() })
        
        var firedTimes = 0
        
        let d1 = observable?.subscribe { _ in
            firedTimes += 1
        }
        
        let d2 = observable?.subscribe { _ in
            firedTimes += 1
        }
        
        
        XCTAssertEqual(firedTimes, 2)
        
        d1?.dispose()
        
        state.update("World")
        
        XCTAssertEqual(firedTimes, 3)
        
        observable = nil
        
        state.update("World!!!")
        
        XCTAssertEqual(firedTimes, 4)
        
        d2?.dispose()
        
        state.update("")
        
        XCTAssertEqual(firedTimes, 4)
    }
    
    func testJetpackButton() {
        let button = UIButton()
        var firedTimes = 0
        
        button.jx.clicked.subscribe {
            firedTimes += 1
        }
        
        button.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(firedTimes, 1)
        
        button.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(firedTimes, 2)
        
        button.jx_reset()
        
        button.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(firedTimes, 2)
        
        let d = button.jx.clicked.subscribe {
            firedTimes += 1
        }
        
        button.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(firedTimes, 3)
        
        d.dispose()
        
        button.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(firedTimes, 3)
    }
    
    func testCombineLatest() {
        let a = Signal<Int>()
        let b = Signal<String>()
        
        var firedTimes = 0
        
        let d = a.combineLatest(b).subscribe {
            firedTimes += 1
            XCTAssertEqual($0.0, 10)
            XCTAssertEqual($0.1, "Hello")
        }
        
        a.update(10)
        b.update("Hello")
        
        XCTAssertEqual(firedTimes, 1)
        
        d.dispose()
        
        a.update(10)
        b.update("Hello")
        
        XCTAssertEqual(firedTimes, 1)
    }
    
    func testCombineLatestSameType() {
        let a = Signal<Int>()
        let b = Signal<Int>()
        let c = Signal<Int>()
        let d = Signal<Int>()
        
        var firedTimes = 0
        
        let disposable = a.combineLatest([b, c, d]).subscribe {
            firedTimes += 1
            XCTAssertEqual($0, [0, 0, 0, 0])
        }
        
        a.update(0)
        b.update(0)
        c.update(0)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 1)
        
        c.update(0)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 3)
        
        disposable.dispose()
        
        c.update(0)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 3)
    }
    
    func testZip() {
        let a = Signal<Int>()
        let b = Signal<Int>()
        let c = Signal<Int>()
        let d = Signal<Int>()
        
        var firedTimes = 0
        
        let disposable = a.zip(b, c, d).subscribe {
            firedTimes += 1
            XCTAssertEqual($0.0, 0)
            XCTAssertEqual($0.1, 0)
            XCTAssertEqual($0.2, 0)
            XCTAssertEqual($0.3, 0)
        }
        
        a.update(0)
        b.update(0)
        c.update(0)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 1)
        
        a.update(0)
        b.update(0)
        
        XCTAssertEqual(firedTimes, 1)
        
        c.update(0)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 2)
        
        a.update(0)
        XCTAssertEqual(firedTimes, 2)
        b.update(0)
        XCTAssertEqual(firedTimes, 2)
        c.update(0)
        XCTAssertEqual(firedTimes, 2)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 3)
        
        disposable.dispose()
        
        c.update(0)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 3)
    }
    
    func testZipSameType() {
        let a = Signal<Int>()
        let b = Signal<Int>()
        let c = Signal<Int>()
        let d = Signal<Int>()
        
        var firedTimes = 0
        
        let disposable = a.zip([b, c, d]).subscribe {
            firedTimes += 1
            XCTAssertEqual($0, [0, 0, 0, 0])
        }
        
        a.update(0)
        b.update(0)
        c.update(0)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 1)
        
        a.update(0)
        b.update(0)
        
        XCTAssertEqual(firedTimes, 1)
        
        c.update(0)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 2)
        
        disposable.dispose()
        
        c.update(0)
        d.update(0)
        
        XCTAssertEqual(firedTimes, 2)
    }
    
    func testCombine() {
        let a = Signal<Int>()
        let b = Signal<String>()
        
        var firedTimes = 0
        var i: Int?
        var s: String?
        
        let d = a.combine(b).subscribe {
            firedTimes += 1
            i = $0.0
            s = $0.1
        }
        
        a.update(10)
        
        XCTAssertEqual(i, 10)
        XCTAssertEqual(s, nil)
        
        
        b.update("Hello")
        
        XCTAssertEqual(i, 10)
        XCTAssertEqual(s, "Hello")
        
        XCTAssertEqual(firedTimes, 2)
        
        d.dispose()
        
        a.update(10)
        b.update("Hello")
        
        XCTAssertEqual(firedTimes, 2)
    }
    
    func testCombine4() {
        let a = Signal<Int>()
        let b = Signal<String>()
        let c = Signal<Int>()
        let d = Signal<String>()
        
        var firedTimes = 0
        var i: Int?
        var s: String?
        var i2: Int?
        var s2: String?
        
        let disposable = a.combine(b, c, d).subscribe {
            firedTimes += 1
            i = $0.0
            s = $0.1
            i2 = $0.2
            s2 = $0.3
        }
        
        a.update(10)
        
        XCTAssertEqual(i, 10)
        XCTAssertEqual(s, nil)
        XCTAssertEqual(i2, nil)
        XCTAssertEqual(s2, nil)
        
        b.update("Hello")
        
        XCTAssertEqual(i, 10)
        XCTAssertEqual(s, "Hello")
        XCTAssertEqual(i2, nil)
        XCTAssertEqual(s2, nil)
        
        c.update(10)
        d.update("Hello")
        XCTAssertEqual(firedTimes, 4)
        
        disposable.dispose()
        
        a.update(10)
        b.update("Hello")
        
        XCTAssertEqual(firedTimes, 4)
    }
    
    func testCombineSameType() {
        let a = Signal<Int>()
        let b = Signal<Int>()
        let c = Signal<Int>()
        let d = Signal<Int>()
        
        var firedTimes = 0
        var a_: Int?
        var b_: Int?
        var c_: Int?
        var d_: Int?
        
        let disposable = a.combine([b, c, d]).subscribe {
            firedTimes += 1
            a_ = $0[0]
            b_ = $0[1]
            c_ = $0[2]
            d_ = $0[3]
        }
        
        a.update(10)
        
        XCTAssertEqual(a_, 10)
        XCTAssertEqual(b_, nil)
        XCTAssertEqual(c_, nil)
        XCTAssertEqual(d_, nil)
        
        b.update(10)
        
        XCTAssertEqual(a_, 10)
        XCTAssertEqual(b_, 10)
        XCTAssertEqual(c_, nil)
        XCTAssertEqual(d_, nil)
        
        c.update(10)
        d.update(10)
        XCTAssertEqual(firedTimes, 4)
        
        disposable.dispose()
        
        a.update(10)
        b.update(10)
        
        XCTAssertEqual(firedTimes, 4)
    }
    
    func testMerge() {
        let a = Signal<Int>()
        let b = Signal<Int>()
        let c = Signal<Int>()
        
        var firedTimes = 0
        
        let disposable = a.merge(b, c).subscribe {
            XCTAssertEqual($0, 0)
            firedTimes += 1
        }
        
        a.update(0)
        XCTAssertEqual(firedTimes, 1)
        
        b.update(0)
        XCTAssertEqual(firedTimes, 2)
        
        c.update(0)
        XCTAssertEqual(firedTimes, 3)
        
        disposable.dispose()
        
        a.update(10)
        b.update(10)
        
        XCTAssertEqual(firedTimes, 3)
    }
    
    func testSample() {
        let a = Signal<Int>()
        let b = Signal<Int>()
        
        var firedTimes = 0
        
        let disposable = a.sample(b).subscribe {
            firedTimes += 1
            XCTAssertEqual($0, 10)
        }
        
        a.update(10)
        XCTAssertEqual(firedTimes, 0)
        
        b.update(0)
        XCTAssertEqual(firedTimes, 1)
        
        b.update(0)
        XCTAssertEqual(firedTimes, 1)
        
        disposable.dispose()
        
        a.update(10)
        b.update(10)
        
        XCTAssertEqual(firedTimes, 1)
    }

    func testWithLatestFrom() {
        let a = Signal<Int>()
        let b = Signal<Int>()
        
        var firedTimes = 0
        
        let disposable = a.withLatestFrom(b).subscribe {
            firedTimes += 1
            XCTAssertEqual($0.0, 10)
            XCTAssertEqual($0.1, 5)
        }
        
        a.update(10)
        a.update(10)
        XCTAssertEqual(firedTimes, 0)
        
        b.update(5)
        XCTAssertEqual(firedTimes, 0)
        
        a.update(10)
        XCTAssertEqual(firedTimes, 1)
        
        disposable.dispose()
        
        a.update(10)
        b.update(5)
        
        XCTAssertEqual(firedTimes, 1)
    }
    
    func testAmb() {
        let a = Signal<Int>()
        let b = Signal<Int>()
        let c = Signal<Int>()
        
        var firedTimes = 0
        
        let disposable = a.amb(b, c).subscribe {
            firedTimes += 1
            XCTAssertEqual($0, 10)
        }
        
        a.update(10)
        a.update(10)
        XCTAssertEqual(firedTimes, 2)
        
        b.update(20)
        XCTAssertEqual(firedTimes, 2)
        
        c.update(30)
        XCTAssertEqual(firedTimes, 2)
        
        disposable.dispose()
        
        a.update(10)
        b.update(5)
        b.update(30)
        
        XCTAssertEqual(firedTimes, 2)
    }
    
    func testBufferSize() {
        let a = Signal<Int>()
        
        var output: [Int] = []
        let disposable = a.buffer(timeInterval: 100, maxSize: 3).subscribe {
            output = $0
        }
        
        a.update(1)
        a.update(2)
        XCTAssertEqual(output, [])
    
        a.update(3)
        XCTAssertEqual(output, [1, 2, 3])
        
        a.update(4)
        a.update(5)
        XCTAssertEqual(output, [1, 2, 3])
        
        a.update(6)
        XCTAssertEqual(output, [4, 5, 6])
        
        disposable.dispose()
        
        a.update(6)
        a.update(6)
        a.update(6)
        
        XCTAssertEqual(output, [4, 5, 6])
    }
    
    func testFlatMapLatest() {
        
        let buttonClick = Signal<Void>()
        
        var genValue = 10
        var expectedValue = 10
        
        let d = buttonClick
            .flatMapLatest {
                return Observer.from(value: genValue)
            }
            .subscribe {
                XCTAssertEqual($0, expectedValue)
            }
        
        buttonClick.update()
        
        genValue = 20
        expectedValue = 20
        
        buttonClick.update()
        
        d.dispose()
        
        genValue = 30
        buttonClick.update()
    }
    
    func testFlatMapLatestTask() {
        
        let buttonClick = Signal<Void>()
        
        var genValue = 10
        let expectedValue = Result(value: 20)
        
        _ = buttonClick
            .flatMapLatest {
                return Task(workerQueue: DispatchQueue.global(qos: .background), worker: { genValue }).asObserver
            }
            .subscribe {
                XCTAssertEqual($0.isEqual(expectedValue), true)
        }
        
        buttonClick.update()
        
        genValue = 20
        buttonClick.update()
    }
    
    func testFlatMapMerge() {
        
        let buttonClick = Signal<Void>()
        
        var genValue = 10
        var expectedValue = 10
        
        let d = buttonClick
            .flatMapMerge {
                return Observer.from(value: genValue)
            }
            .subscribe {
                XCTAssertEqual($0, expectedValue)
        }
        
        buttonClick.update()
        
        genValue = 20
        expectedValue = 20
        
        buttonClick.update()
        
        d.dispose()
        
        genValue = 30
        buttonClick.update()
    }
    
    
    func testNotificationCenter() {
        
        var firedTimes = 0
        
        let disposable = NotificationCenter.default.jx.observer(forName: .UIApplicationDidEnterBackground).subscribe { value in
            firedTimes += 1
            XCTAssertEqual(value?["hello"] as! String, "world")
        }
        
        NotificationCenter.default.post(name: .UIApplicationDidEnterBackground, object: nil, userInfo: ["hello": "world"])
        XCTAssertEqual(firedTimes, 1)

        disposable.dispose()
        
        NotificationCenter.default.post(name: .UIApplicationDidEnterBackground, object: nil, userInfo: ["hello": "world"])
        
        XCTAssertEqual(firedTimes, 1)
    }
    
    
    func testMemory() {
        
        numberOfDeinits = 0
        
        class View {
            private let name = State<String>("John")
            deinit {
                numberOfDeinits += 1
            }
            
            var nameChanged: Observer<String> {
                return name.asObserver
            }
            
            private let value = State<String>("FRP")
            
            var valueReceiver: Receiver<String> {
                return value.asReceiver
            }
            
            private var increment = 0
            private let signal = Signal<Void>()
            
            var signalReceiver: Receiver<Void> {
                return signal.asReceiver
            }
            
            init() {
                signal.subscribe { [weak self] in
                    self?.increment += 1
                }
            }
        }
        
        class Model {
            private let name = State<String>("John")
            deinit {
                numberOfDeinits += 1
            }
            
            var nameReceiver: Receiver<String> {
                return name.asReceiver
            }
            
            private let value = State<String>("FRP")
            
            var valueChanged: Observer<String> {
                return value.asObserver
            }
        }
        
        func scope() {
            let view = View()
            
            let model = Model()

            view.nameChanged.bind(model.nameReceiver)
            model.valueChanged.bind(view.valueReceiver)
            view.nameChanged.bind(view.valueReceiver)
            
            view.nameChanged.just.bind(view.signalReceiver)
        }
        
        scope()
        
        XCTAssertEqual(numberOfDeinits, 2)
    }

    
    func testButtonFlatMap() {
        
        let voidSignal = Signal<Void>()
        let stringSignal = Signal<String>()
        var firedTimes = 0
        
        let d = voidSignal
            .flatMapLatest {[unowned stringSignal] _ in
                return stringSignal.asObserver
            }
            .subscribe { _ in 
                firedTimes += 1
            }
        
        voidSignal.update()
        
        XCTAssertEqual(firedTimes, 0)
        
        stringSignal.update("1")
        
        XCTAssertEqual(firedTimes, 1)
        
        voidSignal.update()
        
        XCTAssertEqual(firedTimes, 1)
        
        stringSignal.update("2")
        
        XCTAssertEqual(firedTimes, 2)
        
        d.dispose()
        
        stringSignal.update("3")
        
        XCTAssertEqual(firedTimes, 2)
    }
}

var numberOfDeinits = 0

#if os(Linux)
extension JetpackTests {
    static var allTests : [(String, (JetpackTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
#endif
