import Service

public struct Bucket: Service {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
