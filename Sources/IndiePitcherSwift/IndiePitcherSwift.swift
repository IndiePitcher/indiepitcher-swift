import Foundation
import Vapor


/// The format of the email body
public enum EmailBodyFormat: String, Content {
    /// The body format is a markdown text
    case markdown
    /// The body format is html text
    case html
}

public enum CustomContactPropertyValue: Codable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case date(Date)
    
    // Coding keys to differentiate between the cases
    private enum CodingKeys: String, CodingKey {
        case string
        case number
        case bool
        case date
    }
    
    // Encoding function
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .date(let value):
            try container.encode(value)
        }
    }
    
    // Decoding function
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Date.self) {
            self = .date(value)
            return
        }
        
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
            return
        }
        
        if let value = try? container.decode(Double.self) {
            self = .number(value)
            return
        }
        
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Data doesn't match either string, number, bool, or date.")
    }
}

/// A contact in the contact list
public struct Contact: Content {
    public init(email: String, userId: String? = nil, avatarUrl: String? = nil, name: String? = nil, hardBouncedAt: Date? = nil, subscribedToLists: [String], customProperties: [String : CustomContactPropertyValue], languageCode: String? = nil) {
        self.email = email
        self.userId = userId
        self.avatarUrl = avatarUrl
        self.name = name
        self.hardBouncedAt = hardBouncedAt
        self.subscribedToLists = subscribedToLists
        self.customProperties = customProperties
        self.languageCode = languageCode
    }
    
    /// The email of the contact
    public var email: String
    /// The user id of the contact
    public var userId: String?
    /// The avatar url of the contact
    public var avatarUrl: String?
    /// The full name of the contact
    public var name: String?
    /// The date when an attempt to send an email to the contact failed with a hard bounce, meaning the email address is invalid and no further emails will be send to this contact. You can reset this in the dashboard to re-enable sending emails to this contact.
    public var hardBouncedAt: Date?
    /// The list of mailing lists the contact is subscribed to.
    public var subscribedToLists: [String]
    /// The custom properties set fort his contact.
    public var customProperties: [String: CustomContactPropertyValue]
    /// The language code of the contact.
    public var languageCode: String?
}

/// The payload to create a new contact
public struct CreateContact: Content {
    public init(email: String, userId: String? = nil, avatarUrl: String? = nil, name: String? = nil, languageCode: String? = nil, updateIfExists: Bool? = nil, subscribedToLists: Set<String>? = nil, customProperties: [String : CustomContactPropertyValue]? = nil) {
        self.email = email
        self.userId = userId
        self.avatarUrl = avatarUrl
        self.name = name
        self.languageCode = languageCode
        self.updateIfExists = updateIfExists
        self.subscribedToLists = subscribedToLists
        self.customProperties = customProperties
    }
    
    /// The email of the contact
    public var email: String
    /// The user id of the contact
    public var userId: String?
    /// The avatar url of the contact
    public var avatarUrl: String?
    /// The full name of the contact
    public var name: String?
    /// The language code of the contact.
    public var languageCode: String?
    /// If a contact with the provided email already exists, update the contact with the new data
    public var updateIfExists: Bool?
    /// The list of mailing lists the contact should be subscribed to. Use the `name` field of the lists.
    public var subscribedToLists: Set<String>?
    /// The custom properties of the contact. Custom properties must be first defined in the IndiePitcher dashboard.
    public var customProperties: [String: CustomContactPropertyValue]?
}

/// The payload to create multiple contacts using a single API call
public struct CreateMultipleContacts: Content {
    public init(contacts: [CreateContact]) {
        self.contacts = contacts
    }
    
    /// The list of contacts to create
    public var contacts: [CreateContact]
}

/// The payload to update a contact in the contact list. 
/// The email is required to identify the contact.
public struct UpdateContact: Content {
    public init(email: String, userId: String? = nil, avatarUrl: String? = nil, name: String? = nil, languageCode: String? = nil, addedListSubscripitons: Set<String>? = nil, removedListSubscripitons: Set<String>? = nil, customProperties: [String : CustomContactPropertyValue?]? = nil) {
        self.email = email
        self.userId = userId
        self.avatarUrl = avatarUrl
        self.name = name
        self.languageCode = languageCode
        self.addedListSubscripitons = addedListSubscripitons
        self.removedListSubscripitons = removedListSubscripitons
        self.customProperties = customProperties
    }
    
    /// The email of the contact
    public var email: String
    /// The user id of the contact
    public var userId: String?
    /// The avatar url of the contact
    public var avatarUrl: String?
    /// The full name of the contact
    public var name: String?
    /// The language code of the contact.
    public var languageCode: String?
    /// The list of mailing lists to subscribe the contact to. Use the `name` field of the lists.
    public var addedListSubscripitons: Set<String>?
    /// The list of mailing lists unsubscribe the contact from. Use the `name` field of the lists.
    public var removedListSubscripitons: Set<String>?
    /// The custom properties of the contact. Custom properties must be first defined in the IndiePitcher dashboard. Pass 'nil' to remove a custom property.
    public var customProperties: [String: CustomContactPropertyValue?]?
}

public struct SendEmail: Content {
    public init(to: String, subject: String, body: String, bodyFormat: EmailBodyFormat) {
        self.to = to
        self.subject = subject
        self.body = body
        self.bodyFormat = bodyFormat
    }
    
    public var to: String
    public var subject: String
    public var body: String
    public var bodyFormat: EmailBodyFormat
}

public struct SendEmailToContact: Content {
    public init(contactEmail: String? = nil, contactEmails: [String]? = nil, subject: String, body: String, bodyFormat: EmailBodyFormat, list: String, delaySeconds: TimeInterval? = nil, delayUntilDate: Date? = nil) {
        self.contactEmail = contactEmail
        self.contactEmails = contactEmails
        self.subject = subject
        self.body = body
        self.bodyFormat = bodyFormat
        self.list = list
        self.delaySeconds = delaySeconds
        self.delayUntilDate = delayUntilDate
    }
    
    public var contactEmail: String?
    public var contactEmails: [String]?
    public var subject: String
    public var body: String
    public var bodyFormat: EmailBodyFormat
    public var list: String
    public var delaySeconds: TimeInterval?
    public var delayUntilDate: Date?
}

public struct SendEmailToContactList: Content {
    public init(subject: String, body: String, bodyFormat: EmailBodyFormat, list: String, delaySeconds: TimeInterval? = nil, delayUntilDate: Date? = nil) {
        self.subject = subject
        self.body = body
        self.bodyFormat = bodyFormat
        self.list = list
        self.delaySeconds = delaySeconds
        self.delayUntilDate = delayUntilDate
    }
    
    public var subject: String
    public var body: String
    public var bodyFormat: EmailBodyFormat
    public var list: String
    public var delaySeconds: TimeInterval?
    public var delayUntilDate: Date?
}


/// Represents a response returning data.
public struct DataResposne<T: Content>: Content {
    /// Always true
    public var success: Bool
    public var data: T
}


/// Represents a response returning no useful data.
public struct EmptyResposne: Content {
    /// Always true
    public var success: Bool
}


/// Represents a response returning paginated data.
public struct PagedDataResponse<T: Content>: Content {
    
    /// Paging metadata
    public struct PageMetadata: Content {
        /// Page index, indexed from 1.
        public let page: Int
        /// Number of results per page
        public let per: Int
        /// Total number of results.
        public let total: Int
    }
    
    /// Always true
    public var success: Bool
    
    /// Returned results
    public var data: T
    
    /// Paging metadata
    public var metadata: PageMetadata
}


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
        URI(stringLiteral: "https://api.indiepitcher.com/v2" + path)
    }
    
    @discardableResult
    /// Add a new contact to the contact list, or update an existing one if `updateIfExists` is set to `true`.
    /// - Parameter contact: Contact properties.
    /// - Returns: Created contact.
    public func addContact(contact: CreateContact) async throws -> DataResposne<Contact> {
        let response = try await client.post(buildUri(path: "/contacts/create"),
                                             headers: commonHeaders,
                                             content: contact)
        return try response.content.decode(DataResposne<Contact>.self)
    }
    
    @discardableResult
    /// Add miultiple contacts (up to 100) using a single API call to avoid being rate limited. Payloads with `updateIfExists` is set to `true` will be updated if a contact with given email already exists.
    /// - Parameter contacts: Contact properties
    /// - Returns: A generic empty response.
    public func addContacts(contacts: [CreateContact]) async throws -> EmptyResposne {
        let response = try await client.post(buildUri(path: "/contacts/create_many"),
                                             headers: commonHeaders,
                                             content: contacts)
        return try response.content.decode(EmptyResposne.self)
    }
    
    @discardableResult
    /// Updates a contact with given email address. This call will fail if a contact with provided email does not exist, use `addContact` instead in such case.
    /// - Parameter contact: Contact properties to update
    /// - Returns: Updated contact.
    public func updateContact(contact: UpdateContact) async throws -> DataResposne<Contact> {
        let response = try await client.post(buildUri(path: "/contacts/update"),
                                             headers: commonHeaders,
                                             content: contact)
        return try response.content.decode(DataResposne<Contact>.self)
    }
    
    @discardableResult
    /// Deletes a contact with provided email from the contact list
    /// - Parameter email: The email address of the contact you wish to remove from the contact list
    /// - Returns: A generic empty response.
    public func deleteContact(email: String) async throws -> EmptyResposne {
        
        struct Payload: Content {
            var email: String
        }
        
        let response = try await client.post(buildUri(path: "/contacts/delete"),
                                             headers: commonHeaders,
                                             content: Payload(email: email))
        
        return try response.content.decode(EmptyResposne.self)
    }
    
    /// Returns a paginated list of stored contacts in the contact list.
    /// - Parameters:
    ///   - page: Page to fetch, the first page has index 1.
    ///   - perPage: How many contacts to return per page.
    /// - Returns: A generic empty response.
    public func listContacts(page: Int = 1, perPage: Int = 10) async throws -> PagedDataResponse<Contact> {
        
        struct Payload: Content {
            let page: Int
            let per: Int
        }
        
        let response = try await client.post(buildUri(path: "/contacts/list"),
                                             headers: commonHeaders,
                                             content: Payload(page: page, per: perPage))
        
        return try response.content.decode(PagedDataResponse<Contact>.self)
    }
    
    @discardableResult
    /// Sends an email to specified email address.
    /// The email is not required to belong to a contact in your contact lsit. Use this API to send emails such as that a user who is not signed up for your product was invited to a team.
    /// - Parameter data: Input params.
    /// - Returns: A genereic response with no return data.
    public func sendEmail(data: SendEmail) async throws -> EmptyResposne {
        let response = try await client.post(buildUri(path: "/email/transactional"),
                                             headers: commonHeaders,
                                             content: data)
        
        return try response.content.decode(EmptyResposne.self)
    }
    
    @discardableResult
    /// Send a personalized email to one more (up to 100 using 1 API call) contacts subscribed to a proviced contact list. This is the recommended way to send an email to members of a team of your product.
    /// All provided emails must belong to your contact list and must be members of provided contact list. All contacts are automatically subscribed to `important` default contact list. You can use peronalization tags such as `Hi {{firstName|default:"there"}}` to peronalize individual sent emails, and scheduled it to be sent with a delay.
    /// - Parameter data: Input params.
    /// - Returns: A genereic response with no return data.
    public func sendEmailToContact(data: SendEmailToContact) async throws -> EmptyResposne {
        let response = try await client.post(buildUri(path: "/email/contact"),
                                             headers: commonHeaders,
                                             content: data)
        
        return try response.content.decode(EmptyResposne.self)
    }
    
    
    @discardableResult
    /// Send a personalized email to all contacts subscribed to a provided contact list. This is the recommendat way to send a newsletter, by creating a list called something like `Newsletter`.
    /// All contacts are automatically subscribed to `important` default contact list. You can use peronalization tags such as `Hi {{firstName|default:"there"}}` to peronalize individual sent emails, and scheduled it to be sent with a delay.
    /// - Parameter data: Input params.
    /// - Returns: A genereic response with no return data.
    public func sendEmailToContactList(data: SendEmailToContactList) async throws -> EmptyResposne {
        let response = try await client.post(buildUri(path: "/email/contact_list"),
                                             headers: commonHeaders,
                                             content: data)
        
        return try response.content.decode(EmptyResposne.self)
    }
}
