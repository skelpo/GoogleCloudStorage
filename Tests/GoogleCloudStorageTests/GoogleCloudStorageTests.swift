import GoogleCloud
import Vapor
import XCTest
@testable import GoogleCloudStorage

extension GoogleCloudStorage {
    static func register(to services: inout Services)throws {
        guard
            let project = Environment.get("GCS_PROJECT"),
            let credentials = Environment.get("GCS_CREDS"),
            let bucket = Environment.get("GCS_BUCKET")
        else {
            throw Abort(.internalServerError, reason: "Missing S3 configuration variable(s)")
        }
        
        let config = GoogleCloudProviderConfig(
            project: project,
            credentialFile: credentials
        )
        let storageConfig = GoogleCloudStorageConfig(
            scope: [StorageScope.fullControl],
            serviceAccount: "google-cloud-storage-test",
            project: project
        )
        
        services.register(config)
        services.register(storageConfig)
        try services.register(GoogleCloudProvider())
        
        services.register(Bucket(name: bucket))
        services.register(GoogleCloudStorage.self)
    }
}
final class GoogleCloudStorageTests: XCTestCase {
    let app: Application = {
        var services = Services.default()
        try! GoogleCloudStorage.register(to: &services)
        
        let config = Config.default()
        let env = try! Environment.detect()
        
        return try! Application(config: config, environment: env, services: services)
    }()
    
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
    
    func testStore()throws {
        let storage = try self.app.make(GoogleCloudStorage.self)
        let file = Vapor.File(data: self.data, filename: "test.md")
        
        let path = try storage.store(file: file, at: "markdown").wait()
        
        XCTAssertEqual(path, "markdown/test.md")
    }
    
    func testFetch()throws {
        let storage = try self.app.make(GoogleCloudStorage.self)
        
        let file = try storage.fetch(file: "markdown/test.md").wait()
        
        XCTAssertEqual(file.filename, "test.md")
        XCTAssertEqual(file.data, self.data)
    }
    
    func testWrite()throws {
        let storage = try self.app.make(GoogleCloudStorage.self)
        
        let updated = try storage.write(file: "markdown/test.md", with: "All new updated data!".data(using: .utf8)!).wait()
        
        XCTAssertEqual(updated.data, "All new updated data!".data(using: .utf8))
        XCTAssertEqual(updated.filename, "test.md")
    }
    
    func testDelete()throws {
        let storage = try self.app.make(GoogleCloudStorage.self)
        try XCTAssertNoThrow(storage.delete(file: "markdown/test.md").wait())
    }
    
    static var allTests: [(String, (GoogleCloudStorageTests) -> ()throws -> ())] = []
}
