![Horizontal logo Brand purple](https://github.com/user-attachments/assets/18beba82-c6e7-4677-87a8-6b374c91bda6)

# IndiePitcher Server-side Swift SDK
Official [IndiePitcher](https://indiepitcher.com) SDK for Swift language.

Provides a type safe layer on top IndiePitcher's public [REST API](https://docs.indiepitcher.com/api-reference/introduction).

## Instalation

The SDK is designed to work with any framework built on top of Swift Nio - Vapor, Hummingbird, or AWS Lamda is supported.

- First, you need to get an API key. Go to the IndiePitcher dashboard, create a project, and generate a public API key.
- Add the key to your `.env` file. Following examples will assume that you've added the key under `IP_SECRET_API_KEY` key.

### Vapor
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


### Hummingbird
TODO


### AWS Lambda
TODO


