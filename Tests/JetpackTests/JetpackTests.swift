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
        
        _ = Observable.from(1)
        _ = Task.from(value: 1)
        _ = Task<Int>.from(error: NSError() )
        
        let value = 10
        let o = Observable.from(value)
        
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
        
        button.click.map { _ in "hello" }.map { $0.uppercased() }.subscribe {
            XCTAssertEqual($0, "HELLO")
        }
        
        button.performClick()
    }
    
    func testState() {
        
        class Test {
            private let state = MutableProperty(0)
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
        
        let state = MutableProperty("Hello")
        
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
    
// this test requires host application
//    func testJetpackButton() {
//        let button = UIButton()
//        var firedTimes = 0
//
//        button.jx.clicked.subscribe {
//            firedTimes += 1
//        }
//
//        button.sendActions(for: .touchUpInside)
//
//        XCTAssertEqual(firedTimes, 1)
//
//        button.sendActions(for: .touchUpInside)
//
//        XCTAssertEqual(firedTimes, 2)
//
//        button.jx_reset()
//
//        button.sendActions(for: .touchUpInside)
//
//        XCTAssertEqual(firedTimes, 2)
//
//        let d = button.jx.clicked.subscribe {
//            firedTimes += 1
//        }
//
//        button.sendActions(for: .touchUpInside)
//
//        XCTAssertEqual(firedTimes, 3)
//
//        d.dispose()
//
//        button.sendActions(for: .touchUpInside)
//
//        XCTAssertEqual(firedTimes, 3)
//    }
    
    func testJetpackButton2() {
        
        let signal = Signal<UIImage>()
        
        do {
            let button = UIButton()
            signal.bind(button.jx.backgroundImage)
        }
        
        signal.update(UIImage())
        
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
                return Observable.from(genValue)
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
        
        buttonClick
            .flatMapLatest {
                return Task(workerQueue: DispatchQueue.global(qos: .background), worker: { .success(genValue) }).asObservable
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
                return Observable.from(genValue)
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
            XCTAssertEqual(value.userInfo?["hello"] as! String, "world")
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
            private let name = MutableProperty<String>("John")
            deinit {
                numberOfDeinits += 1
            }
            
            var nameChanged: Observable<String> {
                return name.asObservable
            }
            
            private let value = MutableProperty<String>("FRP")
            
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
            private let name = MutableProperty<String>("John")
            deinit {
                numberOfDeinits += 1
            }
            
            var nameReceiver: Receiver<String> {
                return name.asReceiver
            }
            
            private let value = MutableProperty<String>("FRP")
            
            var valueChanged: Observable<String> {
                return value.asObservable
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
            .flatMapLatest { _ in
                return stringSignal.asObservable
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
    
    func testDiffSubscribe() {
        let state = MutableProperty(10)
        
        var initial = true
        
        state.diff.subscribe { (oldValue, newValue) in
            if initial {
                XCTAssertEqual(oldValue, 10)
                XCTAssertEqual(newValue, 10)
            } else {
                XCTAssertEqual(oldValue, 10)
                XCTAssertEqual(newValue, 20)
            }
        }
        initial = false
        state.update(20)
    }
    
    func testDistinct() {
        let state = MutableProperty(10)
        
        var ref = 10
        state.distinct.subscribe {
            XCTAssertEqual(ref, $0)
        }
        
        ref = 20
        state.update(10)
        
        state.update(20)
    }
    
    func testDistinctOptional() {
        let state = MutableProperty(Optional.some(10))
        
        var ref: Int? = 10
        state.distinct.subscribe {
            XCTAssertEqual(ref, $0)
        }
        
        ref = 20
        state.update(10)
        
        state.update(20)
        
        ref = nil
        state.update(nil)
    }
    
    func testArrayProperty() {
        let a = MutableArrayProperty<Int>([1,2,3])
        
        var s = [Int]()
        
        a.subscribe {
            switch $0.1 {
            case .set:
                s = $0.0
            case .remove(let idx):
                s.remove(at: idx)
            case .insert(let idx):
                s.insert($0.0[idx], at: idx)
            case .move(let from, let to):
                s.insert(s.remove(at: from), at: to)
            case .update(let idx):
                s[idx] = $0.0[idx]
            }
        }
        
        a.insert(10, at: 0)
        a.move(from: 0, to: 1)
        a.update(at: 2, with: 599)
        a.remove(at: 0)
        
        XCTAssertEqual(a.value, s)
        
        XCTAssertEqual(s, [10, 599, 3])
    }
    
    func testArray2DProperty() {
        let a = MutableArray2DProperty<Int>([[1],[2],[3]])

        var s = [[Int]]()

        a.subscribe {
            switch $0.1 {
            case .set:
                s = $0.0
            case .removeSection(let idx):
                s.remove(at: idx)
            case .insertSection(let idx):
                s.insert($0.0[idx], at: idx)
            case .moveSection(let from, let to):
                s.insert(s.remove(at: from), at: to)
            case .updateSection(let idx):
                s[idx] = $0.0[idx]
            case .removeItem(let idx):
                s[idx.section].remove(at: idx.item)
            case .insertItem(let idx):
                s[idx.section].insert(s[idx.section][idx.row], at: idx.row)
            case .moveItem(let from, let to):
                s[to.section].insert(s[from.section].remove(at: from.row), at: to.row)
            case .updateItem(let idx):
                s[idx.section][idx.row] = $0.0[idx.section][idx.row]
            }
        }

        a.insertSection([0], at: 0)
        a.moveSection(from: 0, to: 1)
        a.updateSection(at: 0, with: [599])
        a.removeSection(at: 0)
        
        a.insertItem(0, at: IndexPath(item: 0, section: 0))
        a.moveItem(from: IndexPath(item: 0, section: 0), to: IndexPath(item: 0, section: 1))
        a.removeItem(at: IndexPath(item: 0, section: 2))
        a.updateItem(at: IndexPath(item: 0, section: 0), with: 599)

        a.value.enumerated().forEach {
            XCTAssertEqual($0.element, s[$0.offset])
        }
        
        XCTAssertEqual(s[0], [599])
        XCTAssertEqual(s[1], [0, 2])
        XCTAssertEqual(s[2], [])
    }
    
    func testWrappedMutableProperty() {
        var a = "1"
        
        let prop = MutableProperty<String>.init(getter: {
            return a
        }) {
            a = $0
        }
        
        let upd1 = "2"
        
        prop.update(upd1)
        
        XCTAssertEqual(upd1, a)
        
        let d = prop.subscribe {
            XCTAssertEqual(upd1, $0)
        }
        d.dispose()
        
        let upd2 = "3"
        
        var control = upd1
        prop.log().subscribe {
            XCTAssertEqual(control, $0)
        }
        control = upd2
        prop.update(upd2)
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
