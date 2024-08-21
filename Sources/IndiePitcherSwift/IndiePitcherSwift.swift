import Foundation
import Vapor

/// IndiePitcher SDK.
/// This SDK is only intended for server-side Swift use. Do not embed the secret API key in client-side code for security reasons.
public struct IndiePitcher {
    private let client: Client
    private let apiKey: String
    
    /// Creates a new instance of IndiePitcher SDK
    /// - Parameters:
    ///   - client: Vapor's client instance to use to perform network requests.
    ///   - apiKey: Your project's secret key.
    public init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }
    
    private var commonHeaders: HTTPHeaders {
        get throws {
            var headers = HTTPHeaders()
            headers.bearerAuthorization = .init(token: apiKey)
            headers.contentType = .json
            return headers
        }
    }
    
    private func buildUri(path: String) -> URI {
        URI(stringLiteral: "https://api.indiepitcher.com/v1" + path)
    }
    
    /// Add a new contact to the mailing list, or update an existing one if `updateIfExists` is set to `true`.
    /// - Parameter contact: Contact properties.
    /// - Returns: Created contact.
    @discardableResult public func addContact(contact: CreateContact) async throws -> DataResponse<Contact> {
        let response = try await client.post(buildUri(path: "/contacts/create"),
                                             headers: commonHeaders,
                                             content: contact)
        return try response.content.decode(DataResponse<Contact>.self)
    }
    
    /// Add miultiple contacts (up to 100) using a single API call to avoid being rate limited. Payloads with `updateIfExists` is set to `true` will be updated if a contact with given email already exists.
    /// - Parameter contacts: Contact properties
    /// - Returns: A generic empty response.
    @discardableResult public func addContacts(contacts: [CreateContact]) async throws -> EmptyResposne {
        let response = try await client.post(buildUri(path: "/contacts/create_many"),
                                             headers: commonHeaders,
                                             content: contacts)
        return try response.content.decode(EmptyResposne.self)
    }
    
    /// Updates a contact with given email address. This call will fail if a contact with provided email does not exist, use `addContact` instead in such case.
    /// - Parameter contact: Contact properties to update
    /// - Returns: Updated contact.
    @discardableResult public func updateContact(contact: UpdateContact) async throws -> DataResponse<Contact> {
        let response = try await client.patch(buildUri(path: "/contacts/update"),
                                             headers: commonHeaders,
                                             content: contact)
        return try response.content.decode(DataResponse<Contact>.self)
    }
    
    /// Deletes a contact with provided email from the mailing list
    /// - Parameter email: The email address of the contact you wish to remove from the mailing list
    /// - Returns: A generic empty response.
    @discardableResult public func deleteContact(email: String) async throws -> EmptyResposne {
        
        struct Payload: Content {
            var email: String
        }
        
        let response = try await client.post(buildUri(path: "/contacts/delete"),
                                             headers: commonHeaders,
                                             content: Payload(email: email))
        
        return try response.content.decode(EmptyResposne.self)
    }
    
    /// Returns a paginated list of stored contacts in the mailing list.
    /// - Parameters:
    ///   - page: Page to fetch, the first page has index 1.
    ///   - perPage: How many contacts to return per page.
    /// - Returns: A paginated array of contacts
    public func listContacts(page: Int = 1, perPage: Int = 10) async throws -> PagedDataResponse<Contact> {
        
        let response = try await client.get(buildUri(path: "/contacts?page=\(page)&per=\(perPage)"),
                                             headers: commonHeaders)
        
        return try response.content.decode(PagedDataResponse<Contact>.self)
    }
    
    /// Sends an email to specified email address.
    /// The email is not required to belong to a contact in your contact lsit. Use this API to send emails such as that a user who is not signed up for your product was invited to a team.
    /// - Parameter data: Input params.
    /// - Returns: A genereic response with no return data.
    @discardableResult public func sendEmail(data: SendEmail) async throws -> EmptyResposne {
        let response = try await client.post(buildUri(path: "/email/transactional"),
                                             headers: commonHeaders,
                                             content: data)
        
        return try response.content.decode(EmptyResposne.self)
    }
    
    /// Send a personalized email to one more (up to 100 using 1 API call) contacts subscribed to a proviced mailing list. This is the recommended way to send an email to members of a team of your product.
    /// All provided emails must belong to your mailing list and must be members of provided mailing list. All contacts are automatically subscribed to `important` default mailing list. You can use peronalization tags such as `Hi {{firstName|default:"there"}}` to peronalize individual sent emails, and scheduled it to be sent with a delay.
    /// - Parameter data: Input params.
    /// - Returns: A genereic response with no return data.
    @discardableResult public func sendEmailToContact(data: SendEmailToContact) async throws -> EmptyResposne {
        let response = try await client.post(buildUri(path: "/email/contact"),
                                             headers: commonHeaders,
                                             content: data)
        
        return try response.content.decode(EmptyResposne.self)
    }
    
    /// Send a personalized email to all contacts subscribed to a provided mailing list. This is the recommendat way to send a newsletter, by creating a list called something like `Newsletter`.
    /// All contacts are automatically subscribed to `important` default mailing list. You can use peronalization tags such as `Hi {{firstName|default:"there"}}` to peronalize individual sent emails, and scheduled it to be sent with a delay.
    /// - Parameter data: Input params.
    /// - Returns: A genereic response with no return data.
    @discardableResult public func sendEmailToMailingList(data: SendEmailToMailingList) async throws -> EmptyResposne {
        let response = try await client.post(buildUri(path: "/email/list"),
                                             headers: commonHeaders,
                                             content: data)
        
        return try response.content.decode(EmptyResposne.self)
    }
    
    /// Returns mailing lists contacts can subscribe to.
    /// - Parameters:
    ///   - page: Page to fetch, the first page has index 1.
    ///   - perPage: How many contacts to return per page.
    /// - Returns: A paginated array of mailing lists
    public func listMailingLists(page: Int = 1, perPage: Int = 10) async throws -> PagedDataResponse<MailingList> {
        
        struct Payload: Content {
            let page: Int
            let per: Int
        }
        
        let response = try await client.get(buildUri(path: "/lists?page=\(page)&per=\(perPage)"),
                                            headers: commonHeaders)
        
        return try response.content.decode(PagedDataResponse<MailingList>.self)
    }
    
    
    /// Generates a new public URL for a contact with provided email to manage their mailing list subscriptions.
    /// - Parameters:
    ///   - contactEmail: The email of a contact this session is for.
    ///   - returnURL: The URL to redirect to when the user is done editing their mailing list, or when the session has expired.
    /// - Returns: Newly created URL session.
    public func createMailingListsPortalSession(contactEmail: String, returnURL: URL) async throws -> DataResponse<MailingListPortalSession> {
        
        struct Payload: Content {
            let contactEmail: String
            let returnURL: URL
        }
        
        let response = try await client.post(buildUri(path: "/lists/portal_session"),
                                             headers: commonHeaders,
                                             content: Payload(contactEmail: contactEmail, returnURL: returnURL))
        
        return try response.content.decode(DataResponse<MailingListPortalSession>.self)
    }
}
