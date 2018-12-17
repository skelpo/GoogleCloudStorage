import XCTest

import GoogleCloudStorageTests

var tests = [XCTestCaseEntry]()
tests += GoogleCloudStorageTests.allTests()
XCTMain(tests)