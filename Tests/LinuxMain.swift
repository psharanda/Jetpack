#if os(Linux)

import XCTest
@testable import JetpackTests

XCTMain([
    testCase(JetpackTests.allTests),
])

#endif
