//
//  Created by Pavel Sharanda
//  Copyright © 2017 Task. All rights reserved.
//

import Foundation
import XCTest
import Jetpack

func requestHello(completion: @escaping (TaskResult<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
        if cancelled {
            completion(.cancelled)
        } else {
            completion(.success("Hello"))
        }
    }
}

func requestError(completion: @escaping (TaskResult<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
        if cancelled {
            completion(.cancelled)
        } else {
            completion(.failure(NSError(domain: "request", code: -1, userInfo: nil)))
        }
    }
}

func requestWorld(head: String, completion: @escaping (TaskResult<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
        if cancelled {
            completion(.cancelled)
        } else {
            completion(.success(head + "World"))
        }
    }
}

func requestPunctuation(head: String, completion: @escaping (TaskResult<String>) -> Void)->(Disposable) {
    return DispatchQueue.main.after(timeInterval: 1) { cancelled in
        if cancelled {
            completion(.cancelled)
        } else {
            completion(.success(head + "!!!"))
        }
    }
}

class TaskTests: XCTestCase {
    
    func testTask() {
        
        let expect = expectation(description: "result")
        
        let r = Task(worker: requestHello)
        
        _ = r.start {
            switch $0 {
            case .success(let value):
                XCTAssertEqual("Hello", value)
            case .cancelled:
                XCTFail("should not be cancelled")
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
        
        let r = Task(worker: requestError)
        _ = r.start {
            switch $0 {
            case .success(_):
                XCTFail("should not have value")
            case .cancelled:
                XCTFail("should not be cancelled")
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
        
        let r = Task(worker: requestHello)
        
        let c = r.start {
            switch $0 {
            case .success(_):
                XCTFail("should not have value")
            case .cancelled:
                break
            case .failure(_):
                XCTFail("should not error")
            }
            expect.fulfill()
        }
        
        c.dispose()
        
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testThen() {
        
        let expect = expectation(description: "result")
        
        let r = Task(worker: requestHello)
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
            case .cancelled:
                XCTFail("should not be cancelled")
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
        
        let r = Task(worker: requestHello)
            .then { result in
                return Task(worker: requestError)
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
            case .cancelled:
                XCTFail("should not be cancelled")
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
        
        let r = Task(worker: requestHello)
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
            case .cancelled:
                break
            case .failure(_):
                XCTFail("should not error")
            }
            expect.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            c.dispose()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testOnSuccess() {
        
        let expect = expectation(description: "result")
        
        let r = Task(worker: requestHello)
            .onSuccess {
                XCTAssertEqual("Hello", $0)
                expect.fulfill()
            }.onCancelled {
                XCTFail("should not be cancelled")
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
        
        let r = Task(worker: requestError)
            .onSuccess { _ in
                XCTFail("should not have value")
                expect.fulfill()
            }.onCancelled {
                XCTFail("should not be cancelled")
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
        
        let r = Task(worker: requestHello)
            .onSuccess { _ in
                XCTFail("should not have value")
                expect.fulfill()
            }.onCancelled {
                expect.fulfill()
            }.onFailure { _ in
                XCTFail("should not error")
                expect.fulfill()
        }
        let c = r.start()
        
        c.dispose()
        
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_cancel() {
        let expect = expectation(description: "result")

        let left = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("Hello"))
                }
            }
        }

        let right = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("Hello"))
                }
            }
        }

        let r = left.race(right)
            .onSuccess { _ in
                XCTFail("shoud not succeed")
                expect.fulfill()
            }
            .onFailure { _ in
                XCTFail("shoud not fail")
                expect.fulfill()
            }
            .onCancelled {
                expect.fulfill()
            }
            .start()

        r.dispose()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testRace_error() {
        let expect = expectation(description: "result")

        let left = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    let error = NSError(domain: "test", code: 0, userInfo: [:])
                    completion(.failure(error))
                }
            }
        }

        let right = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 1) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("Hello"))
                }
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
            .onCancelled {
                XCTFail("shoud not be cancelled 1")
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
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("left"))
                }
            }
        }

        let right = Task<Int> { completion in
            return DispatchQueue.main.after(timeInterval: 1) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success(5))
                }
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
            .onCancelled {
                XCTFail("shoud not be cancelled 2")
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
            return DispatchQueue.main.after(timeInterval: 1) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("left"))
                }
            }
        }

        let right = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("right"))
                }
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
            .onCancelled {
                XCTFail("shoud not be cancelled 3")
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
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("right"))
                }
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
            .onCancelled {
                XCTFail("shoud not be cancelled 3")
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
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r1"))
                }
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.4) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r2"))
                }
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r3"))
                }
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
            .onCancelled {
                XCTFail("shoud not be cancelled")
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
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r1"))
                }
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.4) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    let error = NSError(domain: "test", code: 0, userInfo: [:])
                    completion(.failure(error))
                }
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r3"))
                }
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
            .onCancelled {
                XCTFail("should not be cancelled")
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
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r1"))
                }
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.4) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r2"))
                }
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r3"))
                }
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
            .onCancelled {
                XCTFail("shoud not be cancelled")
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
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r1"))
                }
            }
        }

        let r2 = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.4) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    let error = NSError(domain: "test", code: 0, userInfo: [:])
                    completion(.failure(error))
                }
            }
        }

        let r3 = Task<String> { completion in
            return DispatchQueue.main.after(timeInterval: 0.2) { cancelled in
                if cancelled {
                    completion(.cancelled)
                } else {
                    completion(.success("r3"))
                }
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
            .onCancelled {
                XCTFail("should not be cancelled")
                expect.fulfill()
            }
            .start()

        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testDelayCancelled() {
        
        let expect = expectation(description: "result")
        
        let r = Task<Int>.cancelled.delay(timeInterval: 1)
        
        let cancelable = r.start { result in
            switch result {
            case .cancelled:
                expect.fulfill()
            case .success:
                XCTFail("should not succeed")
                expect.fulfill()
            case .failure:
                XCTFail("shoud not fail")
                expect.fulfill()
            }
        }
        
        _ = DispatchQueue.main.after(timeInterval: 0.5) { _ in
            cancelable.dispose()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testDelayCancelImmediately() {
        
        let expect = expectation(description: "result")
        
        let some = 100
        let r = Task.from(value: some).delay(timeInterval: 1)
        
        let c = r.start { result in
            switch result {
            case .cancelled:
                XCTFail("should not cancel")
                expect.fulfill()
            case .success(let value):
                XCTAssertEqual(some, value)
                expect.fulfill()
            case .failure:
                XCTFail("shoud not fail")
                expect.fulfill()
            }
        }
        
        c.dispose()
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testDelaySuccess() {
        
        let expect = expectation(description: "result")
        
        let some = 100
        let r = Task.from(value: some).delay(timeInterval: 1)
        
        _ = r.start { result in
            switch result {
            case .cancelled:
                XCTFail("should not cancel")
                expect.fulfill()
            case .success(let value):
                XCTAssertEqual(some, value)
                expect.fulfill()
            case .failure:
                XCTFail("shoud not fail")
                expect.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testRetries() {
        
        let expect = expectation(description: "result")
        
        var numberOfFailures = 0
        let r = Task(worker: requestError)
            .onFailure { _ in
                numberOfFailures += 1
            }
            .retry(numberOfTimes: 3, timeout: 0.1)
        
        _ = r.start {
            switch $0 {
            case .success(_):
                XCTFail("should not have value")
            case .cancelled:
                XCTFail("should not be cancelled")
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
        let r = Task(worker: requestError)
            .onFailure { _ in
                numberOfFailures += 1
            }
            .retry(numberOfTimes: 3, timeout: 1)
        
        let cancelable = r.start { result in
            switch result {
            case .cancelled:
                XCTAssertEqual(numberOfFailures, 1)
            case .success(_):
                XCTFail("should not have value")
            case .failure:
                XCTFail("shoud not fail")
            }
            expect.fulfill()
        }
        
        _ = DispatchQueue.main.after(timeInterval: 0.6) { _ in
            cancelable.dispose()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    func testProgressiveTask() {
        
        let expect = expectation(description: "result")
        
        var progress = [Double]()
        
        let r = Task(worker: requestHello)
            .then { result in
                return Task {
                    return requestWorld(head: result, completion: $0)
                }
            }
            .then { result in
                return ProgressiveTask<String, Double> { progress, completion in
                    progress(0.0)
                    progress(0.2)
                    progress(0.4)
                    progress(0.6)
                    progress(0.8)
                    progress(1.0)
                    completion(.success(result+"!!!"))

                    
                    return EmptyDisposable()
                }
                .onProgress { progressValue in
                    progress.append(progressValue)
                }                
            }
        
        _ = r.start {
            switch $0 {
            case .success(let value):
                XCTAssertEqual("HelloWorld!!!", value)
            case .cancelled:
                XCTFail("should not be cancelled")
            case .failure(_):
                XCTFail("should not error")
            }
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertEqual(progress, [0.0, 0.2, 0.4, 0.6, 0.8, 1.0])
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
