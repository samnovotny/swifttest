import XCTest

import swifttestTests

var tests = [XCTestCaseEntry]()
tests += swifttestTests.allTests()
XCTMain(tests)
