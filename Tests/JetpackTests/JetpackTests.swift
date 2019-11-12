//
//  JetpackTests.swift
//  Jetpack
//
//  Created by Pavel Sharanda on {TODAY}.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

import XCTest
import Jetpack

class JetpackTests: XCTestCase {
    
    
    func testObservable() {
        
        class Button {
            
            deinit {
                
            }
            
            var click = PublishSubject<Void>()
            
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
    
    func testCombineLatest() {
        let a = PublishSubject<Int>()
        let b = PublishSubject<String>()
        
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
        let a = PublishSubject<Int>()
        let b = PublishSubject<Int>()
        let c = PublishSubject<Int>()
        let d = PublishSubject<Int>()
        
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
        let a = PublishSubject<Int>()
        let b = PublishSubject<Int>()
        let c = PublishSubject<Int>()
        let d = PublishSubject<Int>()
        
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
        let a = PublishSubject<Int>()
        let b = PublishSubject<Int>()
        let c = PublishSubject<Int>()
        let d = PublishSubject<Int>()
        
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
    
    func testMerge() {
        let a = PublishSubject<Int>()
        let b = PublishSubject<Int>()
        let c = PublishSubject<Int>()
        
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
    
    func testFlatMapLatest() {
        
        let buttonClick = PublishSubject<Void>()
        
        var genValue = 10
        var expectedValue = 10
        
        let d = buttonClick
            .flatMapLatest { _ in
                return Observable.just(genValue)
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
    
    func testFlatMapMerge() {
        
        let buttonClick = PublishSubject<Void>()
        
        var genValue = 10
        var expectedValue = 10
        
        let d = buttonClick
            .flatMapMerge { _ in
                return Observable.just(genValue)
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

    
    func testButtonFlatMap() {
        
        let voidSubject = PublishSubject<Void>()
        let stringSubject = PublishSubject<String>()
        var firedTimes = 0
        
        let d = voidSubject
            .flatMapLatest { _ in
                return stringSubject.asObservable
            }
            .subscribe { _ in 
                firedTimes += 1
            }
        
        voidSubject.update()
        
        XCTAssertEqual(firedTimes, 0)
        
        stringSubject.update("1")
        
        XCTAssertEqual(firedTimes, 1)
        
        voidSubject.update()
        
        XCTAssertEqual(firedTimes, 1)
        
        stringSubject.update("2")
        
        XCTAssertEqual(firedTimes, 2)
        
        d.dispose()
        
        stringSubject.update("3")
        
        XCTAssertEqual(firedTimes, 2)
    }
    
    func testDiffSubscribe() {
        let state = MutableProperty(10)
        
        var initial = true
        
        _ = state.withOldValue.subscribe { (newValue, oldValue) in
            if initial {
                XCTAssertEqual(oldValue, nil)
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
        _ = state.distinctUntilChanged.subscribe {
            XCTAssertEqual(ref, $0)
        }
        
        ref = 20
        state.update(10)
        
        state.update(20)
    }
    
    func testDistinctOptional() {
        let state = MutableProperty(Optional.some(10))
        
        var ref: Int? = 10
        _ = state.distinctUntilChanged.subscribe {
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

        a.append(1)

        var numberOfSets = 0
        _ = a.subscribe {
            switch $0.1 {
            case .set:
                s = $0.0
                numberOfSets += 1
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
        
        XCTAssertEqual(numberOfSets, 1)
        XCTAssertEqual(a.value, s)
        XCTAssertEqual(s, [10, 599, 3, 1])

        a.value = [10]

        XCTAssertEqual(numberOfSets, 2)
        XCTAssertEqual(s, [10])
    }
    
    func testArray2DProperty() {
        let a = MutableArray2DProperty<Int>([[1],[2],[3]])

        var s = [[Int]]()

        _ = a.subscribe {
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
                s[idx.section].insert(s[idx.section][idx.item], at: idx.item)
            case .moveItem(let from, let to):
                s[to.section].insert(s[from.section].remove(at: from.item), at: to.item)
            case .updateItem(let idx):
                s[idx.section][idx.item] = $0.0[idx.section][idx.item]
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
    
    func testDeferred2() {
        var test = 10
        
        let obs = Observable.deferred {
            return 15
        }
        
        XCTAssertEqual(test, 10)
        
        _ = obs.subscribe { val in
            test = val
        }
        
        XCTAssertEqual(test, 15)
    }
    
    func testShareReplay() {
        var sum = 0
        let work = Observable<Int> { observer in
            sum += 1
            observer(sum)
            sum += 1
            observer(sum)
            sum += 1
            observer(sum)
            return EmptyDisposable()
        }
        
        let ro = work.shareReplay(2)
        
        var values = [Int]()
        _ = ro.subscribe {
            values.append($0)
        }
        _ = ro.subscribe {
            values.append($0)
        }
        
        XCTAssertEqual(values, [2, 3, 2, 3])
    }
    
    func testShareReplay2() {
        var values = [Int]()
        let source = PublishSubject<Int>()
        source.update(1)
        let sr = source.shareReplay(1)
        source.update(2)
        let d = sr.subscribe {
            values.append($0)
        }
        source.update(3)
        d.dispose()
        source.update(4)
        _ = sr.subscribe {
            values.append($0)
        }
        source.update(5)
        
        
        XCTAssertEqual(values, [3, 5])
    }
    
    func testThrottle1() {
        let timeIntervals: [TimeInterval] = [
            // curtime - last time - n[!|x]
            0,      // 0 - nil - 0!
            0.05,   // 0.05 - 0 - 1X
            0.01,   // 0.06 - 0 - 2X
            // 0.1 - 0 - 2!
            0.12,   // 0.18 - 0.1 - 3X
            // 0.2 - 0.1 - 3!
            0.09,   // 0.27 - 0.2 - 4X
            // 0.3 - 0.2 - 4!
            0.09,   // 0.36 - 0.3 - 5X
            // 0.4 - 0.3 - 5!
            0.08,   // 0.44 - 0.4 - 6X
            // 0.5 - 0.4 - 6!
            0.12    // 0.56 - 0.5 - 7X
            // 0.6 - 0.5 - 7!
        ]
        testThrottle(timeIntervals: timeIntervals, expectedValues: [0, 2, 3, 4, 5, 6, 7])
    }
    
    func testThrottle2() {
        let timeIntervals: [TimeInterval] = [
            
            // curtime - last time - n[!|x]
            0,      // 0 - nil - 0!
            0.02,   // 0.02 - 0 - 1X
            0.02,   // 0.04 - 0 - 2X
            0.02,   // 0.06 - 0 - 3X
            // 0.1 - 0 - 3!
            0.06,    // 0.12 - 0.1 - 4X
            0.02,   // 0.14 - 0.1 - 5X
            // 0.2 - 0.1 - 5!
        ]
        testThrottle(timeIntervals: timeIntervals, expectedValues: [0, 3, 5])
    }
    
    private func testThrottle(timeIntervals: [TimeInterval], expectedValues: [Int]) {
        
        let expect = expectation(description: "result")
        
        var values = [Int]()
        let source = PublishSubject<Int>()
        
        _ = source.throttle(timeInterval: 0.1, on: .main)
            .subscribe {
                values.append($0)
        }
        
        var deadline = DispatchTime.now()
        timeIntervals.enumerated().forEach { t in
            deadline = deadline + t.element
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                source.update(t.offset)
                if t.offset == timeIntervals.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: deadline + 0.2) {
                        XCTAssertEqual(values, expectedValues)
                        expect.fulfill()
                    }
                }
            }
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testBind() {
        struct Test {
            var isEnabled = false
        }
        
        let p = MutableProperty(Test())
        
        _ = Observable.just(true).bind(to: p) { to, from  in
            to.isEnabled = from
        }
        
        XCTAssertTrue(p.value.isEnabled)
        
        _ = Observable.just(Test()).bind(to: p) { to, from in
            to.isEnabled = from.isEnabled
        }
        
        XCTAssertFalse(p.value.isEnabled)
    }
    
    func testRepeated() {
        
        let expect = expectation(description: "result")
        
        var counter = 0
        
        var d: Disposable?
        d = Observable.repeated(timeInterval: 0.1).subscribe {
            counter += 1
            
            if counter == 5 {
                d?.dispose()
                expect.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(counter, 5)
        }
    }
    
    func testScopedDisposable() {
        var counter = 0
        let p = MutableProperty(())
        
        var d: Disposable? = p.subscribe {
            counter += 1
        }.scoped()
        d = d ?? d
        d = nil
        
        p.update()
        
        XCTAssertEqual(counter, 1)
    }

    func testStressMutableProperty() {
        let numberOfQueues = 20
        let numberOfIteration = 5000
        let prop = MutableProperty(0)
        stressTest(numberOfQueues: numberOfQueues,
                   numberOfIterations: numberOfIteration,
                   when: {  prop.mutate { $0 += 1} },
                   then: { XCTAssertEqual(prop.value, numberOfQueues*numberOfIteration) })
    }
    
    func testStressMutablePropertyOrder() {
        let numberOfQueues = 20
        let numberOfIteration = 50
        let prop = MutableProperty(0)
        
        var counter = 0
        _ = prop.subscribe {
            XCTAssertEqual($0, counter)
            counter += 1
        }
        
        stressTest(numberOfQueues: numberOfQueues,
                   numberOfIterations: numberOfIteration,
                   when: {  prop.mutate { $0 += 1} },
                   then: { XCTAssertEqual(prop.value, numberOfQueues*numberOfIteration) })
    }


    func testStressCombine() {
        let numberOfQueues = 20
        let numberOfIteration = 5000

        let prop1 = MutableProperty(0)
        let prop2 = MutableProperty(0)

        var counter = 0

        _ = prop1.combineLatest(prop2).subscribe { _ in
            counter += 1
        }

        let when = {
            prop1.update(0)
            prop2.update(0)
        }

        let then = {
            XCTAssertEqual(counter, numberOfQueues*numberOfIteration*2 + 1)
        }

        stressTest(numberOfQueues: numberOfQueues, numberOfIterations: numberOfIteration, when: when, then: then)
    }

    func testStressZip() {
        let numberOfQueues = 20
        let numberOfIteration = 5000

        let prop1 = MutableProperty(0)
        let prop2 = MutableProperty(0)

        var counter = 0

        _ = prop1.zip(prop2).subscribe { _ in
            counter += 1
        }

        let when = {
            prop1.update(0)
            prop2.update(0)
        }
        
        stressTest(numberOfQueues: numberOfQueues, numberOfIterations: numberOfIteration, when: when, then: {})
    }

    func testStressTakeFirst() {
        let numberOfQueues = 20
        let numberOfIteration = 5000
        let prop = MutableProperty(0)

        var counter = 0

        let first = 10

        _ = prop.take(first: first).subscribe { _ in
            counter += 1
        }

        stressTest(numberOfQueues: numberOfQueues,
                   numberOfIterations: numberOfIteration,
                   when: {  prop.mutate { $0 += 1} },
                   then: { XCTAssertEqual(counter, first) })
    }

    func testStressTakeWhile() {
        let numberOfQueues = 20
        let numberOfIteration = 5000
        let prop = MutableProperty(0)

        var counter = 0

        let first = numberOfQueues * numberOfIteration - 1

        _ = prop.take(while: { value in
            return value < first

        }).subscribe { _ in
            counter += 1
        }

        stressTest(numberOfQueues: numberOfQueues,
                   numberOfIterations: numberOfIteration,
                   when: {  prop.mutate { $0 += 1} },
                   then: { XCTAssertEqual(counter, first) })
    }
    
    func testStressShareReplay() {
        let numberOfQueues = 20
        let numberOfIteration = 10
        let prop = MutableProperty(0)
        let replay = prop.shareReplay()
        
        _ = stressTest(numberOfQueues: numberOfQueues,
                   numberOfIterations: numberOfIteration,
                   when: {
                    prop.update(0)
                    _ = replay.subscribe { _ in  } },
                   then: {  })
    }
    
    private func stressTest(numberOfQueues: Int,
                            numberOfIterations: Int,
                            when: @escaping ()->Void,
                            then: ()->Void) {

        let group = DispatchGroup()

        for _ in 0..<numberOfQueues {
            group.enter()
            DispatchQueue.global(qos: .utility).async {
                for _ in 0..<numberOfIterations {
                    when()
                }
                group.leave()
            }
        }

        group.wait()

        then()
    }

    func testReactive() {

        let expect = expectation(description: "result")

        class ViewModel {
            @Reactive(ui: true) public private(set) var counter = 0
            @Subject<Void>(ui: true) public private(set) var didFinish

            func touch() {
                _counter.mutableProperty.update(0)
                _didFinish.publishSubject.update()
            }
        }

        let viewModel = ViewModel()

        _ = viewModel.$didFinish.subscribe { _ in
            XCTAssertTrue(Thread.isMainThread)
        }

        _ = viewModel.$counter.subscribe { _ in
            XCTAssertTrue(Thread.isMainThread)
        }

        let numberOfQueues = 20
        let numberOfIterations = 10

        expect.expectedFulfillmentCount = numberOfQueues

        for _ in 0..<numberOfQueues {
            DispatchQueue.global(qos: .utility).async {
                for _ in 0..<numberOfIterations {
                    viewModel.touch()
                }
                expect.fulfill()
            }
        }

        self.waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
        }
    }

    func testDeadlock() {
        let p = MutableProperty(0)

        _ = p.asMainThreadProperty.subscribe { _ in
            _ = p.subscribe { _ in
                p.update(p.value)
            }
        }
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
