//
//  Created by Pavel Sharanda
//  Copyright © 2017 Task. All rights reserved.
//

import Foundation
import XCTest
@testable import Jetpack

func requestHello(completion: @escaping (Result<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
        completion(.success("Hello"))
    }
}

func requestError(completion: @escaping (Result<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
        completion(.failure(NSError(domain: "request", code: -1, userInfo: nil)))
    }
}

func requestWorld(head: String, completion: @escaping (Result<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
        completion(.success(head + "World"))
    }
}

func requestPunctuation(head: String, completion: @escaping (Result<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.jx_after(timeInterval: 1) { cancelled in
        completion(.success(head + "!!!"))
    }
}

class TaskTests: XCTestCase {
    
    func testTask() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestHello)
        
        _ = r.start {
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
        _ = r.start {
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
        
        let c = r.start {
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
            .then { result in
                return Task {
                    return requestWorld(head: result, completion: $0)
                }
            }
            .then { result in
                return Task {
                    return requestPunctuation(head: result, completion: $0)
                }
            }
        
        _ = r.start {
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
            .then { result in
                return Task(generator: requestError)
            }
            .then { result in
                return Task {
                    return requestPunctuation(head: result, completion: $0)
                }
            }
        
        _ = r.start {
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
            .then { result in
                return Task {
                    return requestWorld(head: result, completion: $0)
                }
            }
            .then { result in
                return Task {
                    return requestPunctuation(head: result, completion: $0)
                }
            }
        
        let c = r.start {
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
            .onSuccess {
                XCTAssertEqual("Hello", $0)
                expect.fulfill()
            }.onFailure { _ in
                XCTFail("error")
                expect.fulfill()
            }
        
        _ = r.start()
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testOnError() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestError)
            .onSuccess { _ in
                XCTFail("should not have value")
                expect.fulfill()
            }.onFailure { error in
                XCTAssertEqual(-1, (error as NSError).code)
                expect.fulfill()
            }
        
        
        _ = r.start()
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testOnCancel() {
        
        let expect = expectation(description: "result")
        
        let r = Task(generator: requestHello)
            .onSuccess { _ in
                XCTFail("should not have value")
            }.onFailure { _ in
                XCTFail("should not error")
        }
        let c = r.start()
        
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
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("Hello"))
            }
        }

        let right = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("Hello"))
            }
        }

        let r = left.race(right)
            .onSuccess { _ in
                XCTFail("shoud not succeed")
            }
            .onFailure { _ in
                XCTFail("shoud not fail")
            }
            .start()

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
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                let error = NSError(domain: "test", code: 0, userInfo: [:])
                completion(.failure(error))
            }
        }

        let right = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 1) { cancelled in
                completion(.success("Hello"))
            }
        }

        let _ = left.race(right)
            .onSuccess { _ in
                XCTFail("shoud not succeed")
                expect.fulfill()
            }
            .onFailure { _ in
                expect.fulfill()
            }
            .start()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_success_left() {
        let expect = expectation(description: "result")

        let left = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("left"))
            }
        }

        let right = Task<Int> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 1) { cancelled in
                completion(.success(5))
            }
        }

        let _ = left.race(right)
            .onSuccess { value in
                switch value {
                case .left(let v):
                    XCTAssertEqual(v, "left")
                case .right(_):
                    XCTFail("should be left")
                }
                expect.fulfill()
            }
            .onFailure { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .start()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_success_right() {
        let expect = expectation(description: "result")

        let left = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 1) { cancelled in
                completion(.success("left"))
            }
        }

        let right = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("right"))
            }
        }

        let _ = left.race(right)
            .onSuccess { value in
                switch value {
                case .left(_):
                    XCTFail("should be right")
                case .right(let v):
                    XCTAssertEqual(v, "right")
                }
                expect.fulfill()
            }
            .onFailure { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .start()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_success_immediate() {
        let expect = expectation(description: "result")

        // left succeeds immediately
        let left = Task.from(value: "left")

        let right = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("right"))
            }
        }

        let _ = left.race(right)
            .onSuccess { value in
                switch value {
                case .left(let v):
                    XCTAssertEqual(v, "left")
                case .right(_):
                    XCTFail("should be left")
                }
                expect.fulfill()
            }
            .onFailure { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .start()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testSequence_success() {
        let expect = expectation(description: "result")

        let r1 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("r1"))
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.4) { cancelled in
                completion(.success("r2"))
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("r3"))
            }
        }

        let _ = Task.sequence([r1, r2, r3])
            .onSuccess { value in
                XCTAssertEqual(value, ["r1", "r2", "r3"])
                expect.fulfill()
            }
            .onFailure { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .start()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testSequence_failure() {
        let expect = expectation(description: "result")

        let r1 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("r1"))
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.4) { cancelled in
                let error = NSError(domain: "test", code: 0, userInfo: [:])
                completion(.failure(error))
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("r3"))
            }
        }

        let _ = Task.sequence([r1, r2, r3])
            .onSuccess { value in
                XCTFail("should not succeed")
                expect.fulfill()
            }
            .onFailure { _ in
                expect.fulfill()
            }
            .start()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testConcurrently_success() {
        let expect = expectation(description: "result")

        let r1 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("r1"))
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.4) { cancelled in
                completion(.success("r2"))
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("r3"))
            }
        }

        let _ = Task.concurrently([r1, r2, r3])
            .onSuccess { value in
                XCTAssertEqual(value, ["r1", "r2", "r3"])
                expect.fulfill()
            }
            .onFailure { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .start()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testConcurrently_failure() {
        let expect = expectation(description: "result")

        let r1 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("r1"))
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.4) { cancelled in
                let error = NSError(domain: "test", code: 0, userInfo: [:])
                completion(.failure(error))
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.jx_after(timeInterval: 0.2) { cancelled in
                completion(.success("r3"))
            }
        }

        let _ = Task.concurrently([r1, r2, r3])
            .onSuccess { value in
                XCTFail("should not succeed")
                expect.fulfill()
            }
            .onFailure { _ in
                expect.fulfill()
            }
            .start()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testRetries() {
        
        let expect = expectation(description: "result")
        
        var numberOfFailures = 0
        let r = Task(generator: requestError)
            .onFailure { _ in
                numberOfFailures += 1
            }
            .retry(numberOfTimes: 3, timeout: 0.1)
        
        _ = r.start {
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
            .onFailure { _ in
                numberOfFailures += 1
            }
            .retry(numberOfTimes: 3, timeout: 1)
        
        let cancelable = r.start { result in
            switch result {
            case .success(_):
                XCTFail("should not have value")
            case .failure:
                XCTFail("shoud not fail")
            }
        }
        
        _ = DispatchQueue.main.jx_after(timeInterval: 0.6) { _ in
            cancelable.dispose()
        }
        
        _ = DispatchQueue.main.jx_after(timeInterval: 0.65) { _ in
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
