import NIO
import XCTest
import Storage
import GoogleCloudKit
@testable import GoogleCloudStorage

final class GoogleCloudStorageTests: XCTestCase {
    var eventLoopGroup: EventLoopGroup! = nil
    var storage: Storage! = nil
    
    let data = """
    # Storage

    Test data for the `LocalStorage` instance so we can test it.

    I could use Lorum Ipsum, or I could just sit here and write jibberish like I am now. It might take long, but oh well.

    Listing to the Piano Guys right now.

    Ok, that should be enough bytes for anyone. Unless we are short of the chunk size. I want enough data for at least two chunks of data.

    # Section 2

    ^><<>@<^<>^<>^<>^<>^<>^<>^<>^ open mouth 😮. Hmm, I wonder how that will work
    Maybe if I ran a byte count I could stop typing. But I'm too lazy.

    I hope this is enough.

    # Final
    """.data(using: .utf8)!


    override func setUp() {
        super.setUp()

        guard
            let project = ProcessInfo.processInfo.environment["GCS_PROJECT"],
            let credentials = ProcessInfo.processInfo.environment["GCS_CREDS"],
            let bucket = ProcessInfo.processInfo.environment["GCS_BUCKET"]
        else {
            fatalError("Missing Google Cloud configuration variable(s)")
        }

        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let eventLoop = eventLoopGroup.next()

        do {
            let config = GoogleCloudCredentialsConfiguration(projectId: project, credentialsFile: credentials)
            let storageConfig = GoogleCloudStorageConfiguration(scope: [.fullControl], serviceAccount: "google-cloud-storage-test", project: project)
            let client = try GoogleCloudStorageClient(configuration: config, storageConfig: storageConfig, eventLoop: eventLoop)
            self.storage = GoogleCloudStorage(eventLoop: eventLoop, client: client, bucket: bucket)
        } catch let error {
            fatalError("GCS CLIENT INIT FAILED: \(error.localizedDescription)")
        }
    }

    override func tearDown() {
        do {
            try self.eventLoopGroup.syncShutdownGracefully()
        } catch let error {
            print("ELG SHUTDOWN FAILED:", error)
        }

        self.storage = nil
        self.eventLoopGroup = nil

        super.tearDown()
    }


    func testStore()throws {
        let file = File(data: self.data, filename: "test.md")

        let path = try self.storage.store(file: file, at: "markdown").wait()

        XCTAssertEqual(path, "markdown/test.md")
    }
    
    func testFetch()throws {
        let file = try self.storage.fetch(file: "markdown/test.md").wait()
        
        XCTAssertEqual(file.filename, "test.md")
        XCTAssertEqual(file.data, self.data)
    }
    
    func testWrite()throws {
        let updated = try self.storage.write(file: "markdown/test.md", with: "All new updated data!".data(using: .utf8)!).wait()
        
        XCTAssertEqual(updated.data, "All new updated data!".data(using: .utf8))
        XCTAssertEqual(updated.filename, "test.md")
    }
    
    func testDelete()throws {
        try XCTAssertNoThrow(self.storage.delete(file: "markdown/test.md").wait())
    }
    
    static var allTests: [(String, (GoogleCloudStorageTests) -> ()throws -> ())] = []
}
