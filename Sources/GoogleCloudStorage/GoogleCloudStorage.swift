import GoogleCloud
import Storage
import Vapor

/// A `Storage` interface for Google Cloud Storage, backed by the [google-cloud-provider](https://github.com/vapor-community/google-cloud-provider).
public struct GoogleCloudStorage: Storage, ServiceType {
    
    /// See `ServiceType.makeService(for:)`.
    public static func makeService(for worker: Container) throws -> GoogleCloudStorage {
        let bucket = try worker.make(Bucket.self)
        let client = try worker.make(GoogleCloudStorageClient.self)
        
        return GoogleCloudStorage(worker: worker, client: client, bucket: bucket.name)
    }
    
    
    /// The name of the bucket the files will be stored in.
    public let bucket: String
    
    /// The worker that the service instance lives on.
    public let worker: Worker
    
    
    /// The client instance used for storing, reading, rewriting, and deleting files.
    let client: GoogleCloudStorageClient
    
    
    /// Creates a new `GoogleCloudStorage` instance.
    ///
    /// - Parameters:
    ///   - worker: The worker that the service instance lives on.
    ///   - client: The client used to interact with the Google Cloud API.
    ///   - bucket: The name of the bucket the files will be stored in.
    public init(worker: Worker, client: GoogleCloudStorageClient, bucket: String) {
        self.worker = worker
        self.client = client
        self.bucket = bucket
    }
    
    /// See `Storage.store(file:at:)`.
    public func store(file: File, at path: String?) -> EventLoopFuture<String> {
        do {
            let name = path == nil ? file.filename : path?.last == "/" ? path! + file.filename : path! + "/" + file.filename
            
            return try client.object.createSimpleUpload(
                bucket: self.bucket,
                data: file.data,
                name: name,
                mediaType: file.contentType ?? .plainText,
                queryParameters: nil
            ).map { response in
                print(response.selfLink ?? "nil")
                return ""
            }
        } catch let error {
            return self.worker.future(error: error)
        }
    }
    
    /// See `Storage.fetch(file:)`.
    public func fetch(file: String) -> EventLoopFuture<File> {
        do {
            guard let name = file.split(separator: "/").last.map(String.init) else {
                throw StorageError(identifier: "fileName", reason: "Unable to extract file name from path `\(file)`")
            }
            
            return try self.client.object.getMedia(bucket: self.bucket, objectName: file, queryParameters: nil).map { data in
                return File(data: data, filename: name)
            }
        } catch let error {
            return self.worker.future(error: error)
        }
    }
    
    /// See `Storage.write(file:data:options:)`.
    ///
    /// Google Cloud Storage does not support updating a file's contents, so instead we delete the
    /// current file and create a new one with the updated data.
    ///
    /// The `options` parameter is ignored.
    public func write(file: String, with data: Data, options: Data.WritingOptions) -> EventLoopFuture<File> {
        do {
            guard let name = file.split(separator: "/").last.map(String.init) else {
                throw StorageError(identifier: "fileName", reason: "Unable to extract file name from path `\(file)`")
            }
            
            let path: String = file.split(separator: "/").dropLast().joined()
            let new = File(data: data, filename: name)
            
            return self.delete(file: file).flatMap { _ in
                return self.store(file: new, at: path == "" ? nil : path)
            }.transform(to: new)
        } catch let error {
            return self.worker.future(error: error)
        }
    }
    
    /// See `Storage.delete(file:)`.
    public func delete(file: String) -> EventLoopFuture<Void> {
        do {
            return try self.client.object.delete(bucket: self.bucket, objectName: file, queryParameters: nil).transform(to: ())
        } catch let error {
            return self.worker.future(error: error)
        }
    }
}
