import XCTest
@testable import GoogleCloudStorage

final class GoogleCloudStorageTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(GoogleCloudStorage().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
