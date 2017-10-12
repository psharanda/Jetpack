//
//  Created by Pavel Sharanda
//  Copyright © 2017 Task. All rights reserved.
//

import Foundation
import XCTest
@testable import Jetpack

func requestHello(completion: @escaping (Result<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.jx.after(timeInterval: 0.2) {
        completion(.success("Hello"))
    }
}

func requestError(completion: @escaping (Result<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.jx.after(timeInterval: 0.2) {
        completion(.failure(NSError(domain: "request", code: -1, userInfo: nil)))
    }
}

func requestWorld(head: String, completion: @escaping (Result<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.jx.after(timeInterval: 0.2) {
        completion(.success(head + "World"))
    }
}

func requestPunctuation(head: String, completion: @escaping (Result<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.jx.after(timeInterval: 1) {
        completion(.success(head + "!!!"))
    }
}

class TaskTests: XCTestCase {
    
    func testTask() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestHello)
        
        r.subscribe {
            switch $0 {
            case .success(let value):
                XCTAssertEqual("Hello", value)
            case .failure(_):
                XCTFail("should not error")
            }
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testTaskWithError() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestError)
        r.subscribe {
            switch $0 {
            case .success(_):
                XCTFail("should not have value")
            case .failure(let error):
                XCTAssertEqual(-1, (error as NSError).code)
            }
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testTaskCancel() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestHello)
        
        let c = r.subscribe {
            switch $0 {
            case .success(_):
                XCTFail("should not have value")
            case .failure(_):
                XCTFail("should not error")
            }
            
        }
        
        c.dispose()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testThen() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestHello)
            .flatMapLatestValue { result in
                return Task {
                    return requestWorld(head: result, completion: $0)
                }
            }
            .flatMapLatestValue { result in
                return Task {
                    return requestPunctuation(head: result, completion: $0)
                }
            }
        
        r.subscribe {
            switch $0 {
            case .success(let value):
                XCTAssertEqual("HelloWorld!!!", value)
            case .failure(_):
                XCTFail("should not error")
            }
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testThenError() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestHello)
            .flatMapLatestValue { result in
                return Task(generator: requestError)
            }
            .flatMapLatestValue { result in
                return Task {
                    return requestPunctuation(head: result, completion: $0)
                }
            }
        
        r.subscribe {
            switch $0 {
            case .success(_):
                XCTFail("should not have value")
            case .failure(let error):
                XCTAssertEqual(-1, (error as NSError).code)
            }
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testThenCancel() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestHello)
            .flatMapLatestValue { result in
                return Task {
                    return requestWorld(head: result, completion: $0)
                }
            }
            .flatMapLatestValue { result in
                return Task {
                    return requestPunctuation(head: result, completion: $0)
                }
            }
        
        let c = r.subscribe {
            switch $0 {
            case .success(_):
                XCTFail("should not have value")
            case .failure(_):
                XCTFail("should not error")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            c.dispose()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testOnSuccess() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestHello)
            .forEachValue {
                XCTAssertEqual("Hello", $0)
                expect.fulfill()
            }.forEachError { _ in
                XCTFail("error")
                expect.fulfill()
            }
        
        r.subscribe()
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testOnError() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestError)
            .forEachValue { _ in
                XCTFail("should not have value")
                expect.fulfill()
            }.forEachError { error in
                XCTAssertEqual(-1, (error as NSError).code)
                expect.fulfill()
            }
        
        
        r.subscribe()
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testOnCancel() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestHello)
            .forEachValue { _ in
                XCTFail("should not have value")
            }.forEachError { _ in
                XCTFail("should not error")
        }
        let c = r.subscribe()
        
        c.dispose()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_cancel() {
        let expect = expectation(description: "result")

        let left = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("Hello"))
            }
        }

        let right = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("Hello"))
            }
        }

        let r = left.race(right)
            .forEachValue { _ in
                XCTFail("shoud not succeed")
            }
            .forEachError { _ in
                XCTFail("shoud not fail")
            }
            .subscribe()

        r.dispose()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expect.fulfill()
        }

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_error() {
        let expect = expectation(description: "result")

        let left = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                let error = NSError(domain: "test", code: 0, userInfo: [:])
                completion(.failure(error))
            }
        }

        let right = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 1) {
                completion(.success("Hello"))
            }
        }

        left.race(right)
            .forEachValue { _ in
                XCTFail("shoud not succeed")
                expect.fulfill()
            }
            .forEachError { _ in
                expect.fulfill()
            }
            .subscribe()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_success_left() {
        let expect = expectation(description: "result")

        let left = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("left"))
            }
        }

        let right = Task<Int> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 1) {
                completion(.success(5))
            }
        }

        left.race(right)
            .forEachValue { value in
                switch value {
                case .left(let v):
                    XCTAssertEqual(v, "left")
                case .right(_):
                    XCTFail("should be left")
                }
                expect.fulfill()
            }
            .forEachError { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .subscribe()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_success_right() {
        let expect = expectation(description: "result")

        let left = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 1) {
                completion(.success("left"))
            }
        }

        let right = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("right"))
            }
        }

        left.race(right)
            .forEachValue { value in
                switch value {
                case .left(_):
                    XCTFail("should be right")
                case .right(let v):
                    XCTAssertEqual(v, "right")
                }
                expect.fulfill()
            }
            .forEachError { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .subscribe()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_success_immediate() {
        let expect = expectation(description: "result")

        // left succeeds immediately
        let left = Task.from(value: "left")

        let right = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("right"))
            }
        }

        left.race(right)
            .forEachValue { value in
                switch value {
                case .left(let v):
                    XCTAssertEqual(v, "left")
                case .right(_):
                    XCTFail("should be left")
                }
                expect.fulfill()
            }
            .forEachError { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .subscribe()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testSequence_success() {
        let expect = expectation(description: "result")

        let r1 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("r1"))
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.4) {
                completion(.success("r2"))
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("r3"))
            }
        }

        Task.sequence([r1, r2, r3])
            .forEachValue { value in
                XCTAssertEqual(value, ["r1", "r2", "r3"])
                expect.fulfill()
            }
            .forEachError { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .subscribe()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testSequence_failure() {
        let expect = expectation(description: "result")

        let r1 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("r1"))
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.4) {
                let error = NSError(domain: "test", code: 0, userInfo: [:])
                completion(.failure(error))
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("r3"))
            }
        }

        Task.sequence([r1, r2, r3])
            .forEachValue { value in
                XCTFail("should not succeed")
                expect.fulfill()
            }
            .forEachError { _ in
                expect.fulfill()
            }
            .subscribe()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testConcurrently_success() {
        let expect = expectation(description: "result")

        let r1 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("r1"))
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.4) {
                completion(.success("r2"))
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("r3"))
            }
        }

        Task.concurrently([r1, r2, r3])
            .forEachValue { value in
                XCTAssertEqual(value, ["r1", "r2", "r3"])
                expect.fulfill()
            }
            .forEachError { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .subscribe()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testConcurrently_failure() {
        let expect = expectation(description: "result")

        let r1 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("r1"))
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.4) {
                let error = NSError(domain: "test", code: 0, userInfo: [:])
                completion(.failure(error))
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.jx.after(timeInterval: 0.2) {
                completion(.success("r3"))
            }
        }

        Task.concurrently([r1, r2, r3])
            .forEachValue { value in
                XCTFail("should not succeed")
                expect.fulfill()
            }
            .forEachError { _ in
                expect.fulfill()
            }
            .subscribe()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testRetries() {
        
        let expect = expectation(description: "result")
        
        var numberOfFailures = 0
        let r = Task(generator: requestError)
            .forEachError { _ in
                numberOfFailures += 1
            }
            .retry(numberOfTimes: 3, timeout: 0.1)
        
        r.subscribe {
            switch $0 {
            case .success(_):
                XCTFail("should not have value")
            case .failure:
                XCTAssertEqual(numberOfFailures, 4)
            }
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testRetriesCancelled() {
        
        let expect = expectation(description: "result")
        
        var numberOfFailures = 0
        let r = Task(generator: requestError)
            .forEachError { _ in
                numberOfFailures += 1
            }
            .retry(numberOfTimes: 3, timeout: 1)
        
        let cancelable = r.subscribe { result in
            switch result {
            case .success(_):
                XCTFail("should not have value")
            case .failure:
                XCTFail("shoud not fail")
            }
        }
        
        DispatchQueue.main.jx.after(timeInterval: 0.6) {
            cancelable.dispose()
        }
        
        DispatchQueue.main.jx.after(timeInterval: 0.65) { 
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
}

#if os(Linux)
extension TaskTests {
    static var allTests : [(String, (TaskTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
#endif
