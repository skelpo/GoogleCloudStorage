import GoogleCloudKit
import Foundation
import Storage
import NIO

/// A `Storage` interface for Google Cloud Storage, backed by the [GoogleCloudKit](https://github.com/vapor-community/GoogleCloudKit).
public struct GoogleCloudStorage: Storage {
    
    /// The name of the bucket the files will be stored in.
    public let bucket: String
    
    /// The event-loop that the service instance lives on.
    public let eventLoop: EventLoop
    
    
    /// The client instance used for storing, reading, rewriting, and deleting files.
    let client: GoogleCloudStorageClient
    
    
    /// Creates a new `GoogleCloudStorage` instance.
    ///
    /// - Parameters:
    ///   - eventLoop: The event-loop that the service instance lives on.
    ///   - client: The client used to interact with the Google Cloud API.
    ///   - bucket: The name of the bucket the files will be stored in.
    public init(eventLoop: EventLoop, client: GoogleCloudStorageClient, bucket: String) {
        self.eventLoop = eventLoop
        self.client = client
        self.bucket = bucket
    }
    
    /// See `Storage.store(file:at:)`.
    public func store(file: File, at path: String? = nil) -> EventLoopFuture<String> {
        let name = path == nil ? file.filename : path?.last == "/" ? path! + file.filename : path! + "/" + file.filename

        return client.object.createSimpleUpload(
            bucket: self.bucket,
            data: file.data,
            name: name,
            contentType: "text/plain",
            queryParameters: nil
        ).map { response in
            return response.name ?? name
        }
    }
    
    /// See `Storage.fetch(file:)`.
    public func fetch(file: String) -> EventLoopFuture<File> {
        do {
            guard let name = file.split(separator: "/").last.map(String.init) else {
                throw StorageError(identifier: "fileName", reason: "Unable to extract file name from path `\(file)`")
            }
            guard let path = file.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                throw StorageError(identifier: "pathEncoding", reason: "File percent encoding failed")
            }
            
            return self.client.object.getMedia(bucket: self.bucket, object: path, queryParameters: nil).map { data in
                return File(data: data.data ?? Data(), filename: name)
            }
        } catch let error {
            return self.eventLoop.makeFailedFuture(error)
        }
    }
    
    /// See `Storage.write(file:data:options:)`.
    ///
    /// Google Cloud Storage does not support updating a file's contents, so instead we delete the
    /// current file and create a new one with the updated data.
    ///
    /// The `options` parameter is ignored.
    public func write(file: String, with data: Data) -> EventLoopFuture<File> {
        do {
            guard let name = file.split(separator: "/").last.map(String.init) else {
                throw StorageError(identifier: "fileName", reason: "Unable to extract file name from path `\(file)`")
            }
            
            let path: String = file.split(separator: "/").dropLast().joined()
            let new = File(data: data, filename: name)
            
            return self.delete(file: file).flatMap { _ in
                return self.store(file: new, at: path == "" ? nil : path)
            }.map { _ in new }
        } catch let error {
            return self.eventLoop.makeFailedFuture(error)
        }
    }
    
    /// See `Storage.delete(file:)`.
    public func delete(file: String) -> EventLoopFuture<Void> {
        do {
            guard let path = file.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                throw StorageError(identifier: "pathEncoding", reason: "File percent encoding failed")
            }
            
            return self.client.object.delete(bucket: self.bucket, object: path, queryParameters: nil).map { _ in () }
        } catch let error {
            return self.eventLoop.makeFailedFuture(error)
        }
    }
}
