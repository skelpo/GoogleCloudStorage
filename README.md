# GoogleCloudStorage


An implementation of [skelpo/Storage](https://github.com/skelpo/Storage) for Amazon S3. Uses the [google-cloud-provider](https://github.com/vapor-community/google-cloud-provider) package for interacting with the S3 API.

## Installing

Add the package declaration to your manifest's `dependencies` array with the [latest version](https://github.com/skelpo/GoogleCloudStorage/releases/latest):

```swift
.package(url: "https://github.com/skelpo/GoogleCloudStorage.git", from: "0.1.0")
```

Then run `swift package update` and regenerate your Xcode project (if you have one).

## Configuration

Register `GoogleCloudProviderConfig`, `GoogleCloudStorageConfig`, and `GoogleCloudProvider` instances with your app's services.

Then you can either register a `GoogleCloudStorage` instance or register the `GoogleCloudStorage` type:

```swift
services.register { container in
	return try GoogleCloudStorage(worker: container, client: container.make(), bucket: "myproject-31415")
}
```

Or

```swift
services.register(Bucket(name: "myproject-31415"))
try services.register(GoogleCloudStorage.self)
```

## API

You can find API documentation [here](http://www.skelpo.codes/GoogleCloudStorage/).

## License

GoogleCloudStorage is under the [MIT license agreement](https://github.com/skelpo/GoogleCloudStorage/blob/master/LICENSE).
