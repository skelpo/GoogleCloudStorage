import Service

/// A service used to store the name of the bucket to store files in.
public struct Bucket: Service {
    
    /// The name of the bucket to use.
    public let name: String
    
    /// Creates a new `Bucket` service instance.
    ///
    /// - Parameter name: The name of the bucket to use.
    public init(name: String) {
        self.name = name
    }
}
