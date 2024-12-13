import Foundation
import AsyncHTTPClient
import NIO
import NIOCore
import NIOHTTP1
import NIOFoundationCompat

extension HTTPClientResponse {
    var isOk: Bool {
        status.code >= 200 && status.code < 300
    }
}

/// IndiePitcher SDK.
/// This SDK is only intended for server-side Swift use. Do not embed the secret API key in client-side code for security reasons.
public struct IndiePitcher: Sendable {
    private let client: HTTPClient // is sendable / thread-safe
    private let apiKey: String
    private let requestTimeout: TimeAmount = .seconds(30)
    private let maxResponseSize = 1024 * 1024 * 100
    
    /// Creates a new instance of IndiePitcher SDK
    /// - Parameters:
    ///   - client: Vapor's client instance to use to perform network requests. Uses the  shared client by default.
    ///   - apiKey: Your project's secret key.
    public init(client: HTTPClient = .shared, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }
    
    // MARK: networking
    
    private var commonHeaders: HTTPHeaders {
        get {
            var headers = HTTPHeaders()
            headers.add(name: "Authorization", value: "Bearer \(apiKey)")
            headers.add(name: "User-Agent", value: "IndiePitcherSwift")
            return headers
        }
    }
    
    private var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    private func buildUri(path: String) -> String {
        "https://api.indiepitcher.com/v1" + path
    }
    
    private func post<T: Codable>(path: String, body: Codable) async throws -> T {
        
        var headers = commonHeaders
        headers.add(name: "Content-Type", value: "application/json")
        
        var request = HTTPClientRequest(url: buildUri(path: path))
        request.method = .POST
        request.headers = headers
        request.body = .bytes(.init(data: try jsonEncoder.encode(body)))
        
        let response = try await client.execute(request, timeout: requestTimeout)
        let responseData = try await response.body.collect(upTo: maxResponseSize)
        
        guard response.isOk else {
            let error = try? jsonDecoder.decode(ErrorResponse.self, from: responseData)
            throw IndiePitcherRequestError(statusCode: response.status.code, reason: error?.reason ?? "Unknown reason")
        }
        
        return try self.jsonDecoder.decode(T.self, from: responseData)
    }
    
    private func patch<T: Codable>(path: String, body: Codable) async throws -> T {
        
        var headers = commonHeaders
        headers.add(name: "Content-Type", value: "application/json")
        
        var request = HTTPClientRequest(url: buildUri(path: path))
        request.method = .PATCH
        request.headers = headers
        request.body = .bytes(.init(data: try jsonEncoder.encode(body)))
        
        let response = try await client.execute(request, timeout: requestTimeout)
        let responseData = try await response.body.collect(upTo: maxResponseSize)
        
        guard response.isOk else {
            let error = try? jsonDecoder.decode(ErrorResponse.self, from: responseData)
            throw IndiePitcherRequestError(statusCode: response.status.code, reason: error?.reason ?? "Unknown reason")
        }
        
        return try self.jsonDecoder.decode(T.self, from: responseData)
    }
    
    private func get<T: Codable>(path: String) async throws -> T {
        
        let headers = commonHeaders
        
        var request = HTTPClientRequest(url: buildUri(path: path))
        request.method = .GET
        request.headers = headers
        
        let response = try await client.execute(request, timeout: requestTimeout)
        let responseData = try await response.body.collect(upTo: maxResponseSize)
        
        guard response.isOk else {
            let error = try? jsonDecoder.decode(ErrorResponse.self, from: responseData)
            throw IndiePitcherRequestError(statusCode: response.status.code, reason: error?.reason ?? "Unknown reason")
        }
        
        return try self.jsonDecoder.decode(T.self, from: responseData)
    }
    
    // MARK: API calls
    
    /// Add a new contact to the mailing list, or update an existing one if `updateIfExists` is set to `true`.
    /// - Parameter contact: Contact properties.
    /// - Returns: Created contact.
    @discardableResult public func addContact(contact: CreateContact) async throws -> DataResponse<Contact> {
        try await post(path: "/contacts/create", body: contact)
    }
    
    /// Add miultiple contacts (up to 100) using a single API call to avoid being rate limited. Payloads with `updateIfExists` is set to `true` will be updated if a contact with given email already exists.
    /// - Parameter contacts: Contact properties
    /// - Returns: A generic empty response.
    @discardableResult public func addContacts(contacts: [CreateContact]) async throws -> EmptyResposne {
        
        struct Payload: Codable {
            let contacts: [CreateContact]
        }
        
        return try await post(path: "/contacts/create_many", body: Payload(contacts: contacts))
    }
    
    /// Updates a contact with given email address. This call will fail if a contact with provided email does not exist, use `addContact` instead in such case.
    /// - Parameter contact: Contact properties to update
    /// - Returns: Updated contact.
    @discardableResult public func updateContact(contact: UpdateContact) async throws -> DataResponse<Contact> {
        try await patch(path: "/contacts/update", body: contact)
    }
    
    /// Deletes a contact with provided email from the mailing list
    /// - Parameter email: The email address of the contact you wish to remove from the mailing list
    /// - Returns: A generic empty response.
    @discardableResult public func deleteContact(email: String) async throws -> EmptyResposne {
        
        struct Payload: Codable {
            var email: String
        }
        
        return try await post(path: "/contacts/delete", body: Payload(email: email))
    }
    
    /// Returns a paginated list of stored contacts in the mailing list.
    /// - Parameters:
    ///   - page: Page to fetch, the first page has index 1.
    ///   - perPage: How many contacts to return per page.
    /// - Returns: A paginated array of contacts
    public func listContacts(page: Int = 1, perPage: Int = 10) async throws -> PagedDataResponse<Contact> {
        try await get(path: "/contacts?page=\(page)&per=\(perPage)")
    }
    
    /// Sends an email to specified email address.
    /// The email is not required to belong to a contact in your contact lsit. Use this API to send emails such as that a user who is not signed up for your product was invited to a team.
    /// - Parameter data: Input params.
    /// - Returns: A genereic response with no return data.
    @discardableResult public func sendEmail(data: SendEmail) async throws -> EmptyResposne {
        try await post(path: "/email/transactional", body: data)
    }
    
    /// Send a personalized email to one more (up to 100 using 1 API call) contacts subscribed to a proviced mailing list. This is the recommended way to send an email to members of a team of your product.
    /// All provided emails must belong to your mailing list and must be members of provided mailing list. All contacts are automatically subscribed to `important` default mailing list. You can use peronalization tags such as `Hi {{firstName}}` to peronalize individual sent emails, and scheduled it to be sent with a delay.
    /// - Parameter data: Input params.
    /// - Returns: A genereic response with no return data.
    @discardableResult public func sendEmailToContact(data: SendEmailToContact) async throws -> EmptyResposne {
        try await post(path: "/email/contact", body: data)
    }
    
    /// Send a personalized email to all contacts subscribed to a provided mailing list. This is the recommendat way to send a newsletter, by creating a list called something like `Newsletter`.
    /// All contacts are automatically subscribed to `important` default mailing list. You can use peronalization tags such as `Hi {{firstName}}` to peronalize individual sent emails, and scheduled it to be sent with a delay.
    /// - Parameter data: Input params.
    /// - Returns: A genereic response with no return data.
    @discardableResult public func sendEmailToMailingList(data: SendEmailToMailingList) async throws -> EmptyResposne {
        try await post(path: "/email/list", body: data)
    }
    
    /// Returns mailing lists contacts can subscribe to.
    /// - Parameters:
    ///   - page: Page to fetch, the first page has index 1.
    ///   - perPage: How many contacts to return per page.
    /// - Returns: A paginated array of mailing lists
    public func listMailingLists(page: Int = 1, perPage: Int = 10) async throws -> PagedDataResponse<MailingList> {
        
        struct Payload: Codable {
            let page: Int
            let per: Int
        }
        
        return try await get(path: "/lists?page=\(page)&per=\(perPage)")
    }
    
    
    /// Generates a new public URL for a contact with provided email to manage their mailing list subscriptions.
    /// - Parameters:
    ///   - contactEmail: The email of a contact in your project's contact list, who to create the portal session for.
    ///   - returnURL: The URL to redirect to when the user is done editing their mailing list, or when the session has expired.
    /// - Returns: The URL to redirect your user to, and the expiration date of the session.
    public func createMailingListsPortalSession(contactEmail: String, returnURL: URL) async throws -> DataResponse<MailingListPortalSession> {
        
        struct Payload: Codable {
            let contactEmail: String
            let returnURL: URL
        }
        
        return try await post(path: "/lists/portal_session", body: Payload(contactEmail: contactEmail, returnURL: returnURL))
    }
}
