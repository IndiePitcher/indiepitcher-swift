![Horizontal logo Brand purple](https://github.com/user-attachments/assets/18beba82-c6e7-4677-87a8-6b374c91bda6)

# IndiePitcher Server-side Swift SDK
Official [IndiePitcher](https://indiepitcher.com) SDK for Swift language.

Provides a type safe layer on top IndiePitcher's public [REST API](https://docs.indiepitcher.com/api-reference/introduction).

SDK documentation can be found [here](https://swiftpackageindex.com/indiepitcher/indiepitcher-swift/main/documentation/indiepitcherswift/indiepitcher).

## Instalation

The SDK is designed to work with any framework built on top of Swift Nio - Vapor, Hummingbird, or AWS Lamda is supported.

1) Add the dependency to your `Package.swift` file
```swift
.package(url: "https://github.com/IndiePitcher/indiepitcher-swift.git", from: "1.0.0"),
```

2) Add IndiePitcher to appropriate target(s) of your project
```swift
.product(name: "IndiePitcherSwift", package: "indiepitcher-swift")
```

You can also use the CLI instead
```bash
swift package add-dependency https://github.com/IndiePitcher/indiepitcher-swift.git --from 1.0.0
swift package add-target-dependency IndiePitcherSwift --package indiepitcher-swift MyTarget
```


**Using the SDK:**
- First, you need to get an API key. Go to the IndiePitcher dashboard, create a project, and generate a public API key.
- Add the key to your `.env` file. Following examples will assume that you've added the key under `IP_SECRET_API_KEY` key.

### Vapor 4
Create a new file, something like `Application+IndiePitcher.swift` and paste in following code
```swift
import Vapor
import IndiePitcherSwift

extension Request {
    var indiePitcher: IndiePitcher {
        guard let apiKey = Environment.get("IP_V2_SECRET_API_KEY") else {
            fatalError("IP_V2_SECRET_API_KEY env key missing")
        }

        return .init(client: application.http.client.shared, apiKey: apiKey)
    }
}

extension Application {
    var indiePitcher: IndiePitcher {
        guard let apiKey = Environment.get("IP_V2_SECRET_API_KEY") else {
            fatalError("IP_V2_SECRET_API_KEY env key missing")
        }

        return .init(client: http.client.shared, apiKey: apiKey)
    }
}
```

This will give you easy access to the SDK methods using `application` and `request`.
```swift
app.get { req async in
    try await req.indiePitcher.listContacts()
}
```


### Hummingbird 2
TODO


### AWS Lambda
This is how you can send an email from within an AWS Lambda function. See the [full example repository](https://github.com/IndiePitcher/IndiePitcherLambdaSwiftExample).
```swift
@main
struct MyLambda: SimpleLambdaHandler {

    private let indiePitcherApiKey = "sc_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    func handle(_ event: String, context: LambdaContext) async throws -> String {

        let indiePitcher = IndiePitcher(apiKey: indiePitcherApiKey)

        let emailBody = """
            This is an email sent from a **AWS Lambda function**!
            """

        try await indiePitcher.sendEmail(
            data: .init(
                to: "petr@indiepitcher.com", subject: "Hello from ASS Lambda!", body: emailBody,
                bodyFormat: .markdown))

        return "Email sent!"
    }
}
```


