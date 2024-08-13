import Foundation
import Vapor

public enum EmailBodyFormat: String, Content {
    case markdown
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

public struct Contact: Content {
    public init(email: String, userId: String? = nil, avatarUrl: String? = nil, name: String? = nil, hardBouncedAt: Date? = nil, subscribedToLists: [String], customProperties: [String : CustomContactPropertyValue]) {
        self.email = email
        self.userId = userId
        self.avatarUrl = avatarUrl
        self.name = name
        self.hardBouncedAt = hardBouncedAt
        self.subscribedToLists = subscribedToLists
        self.customProperties = customProperties
    }
    
    public var email: String
    public var userId: String?
    public var avatarUrl: String?
    public var name: String?
    public var hardBouncedAt: Date?
    public var subscribedToLists: [String]
    public var customProperties: [String: CustomContactPropertyValue]
}

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
    
    public var email: String
    public var userId: String?
    public var avatarUrl: String?
    public var name: String?
    public var languageCode: String?
    public var updateIfExists: Bool?
    public var subscribedToLists: Set<String>?
    public var customProperties: [String: CustomContactPropertyValue]?
}

public struct CreateMultipleContacts: Content {
    public init(contacts: [CreateContact]) {
        self.contacts = contacts
    }
    
    public var contacts: [CreateContact]
}

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
    
    public var email: String
    public var userId: String?
    public var avatarUrl: String?
    public var name: String?
    public var languageCode: String?
    public var addedListSubscripitons: Set<String>?
    public var removedListSubscripitons: Set<String>?
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

public struct DataResposne<T: Content>: Content {
    public var success: Bool = true
    public var data: T
}

public struct EmptyResposne: Content {
    public var success: Bool = true
}

public struct PagedDataResponse<T: Content>: Content {
    
    public struct PageMetadata: Content {
        public let page: Int
        public let per: Int
        public let total: Int
    }
    
    public var success: Bool = true
    public var data: T
    public var metadata: PageMetadata
}

public struct IndiePitcher {
    private let client: Client
    private let apiKey: String
    
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
    
    public func addContact(contact: CreateContact) async throws -> DataResposne<Contact> {
        let response = try await client.post(buildUri(path: "/contacts/create"),
                                             headers: commonHeaders,
                                             content: contact)
        return try response.content.decode(DataResposne<Contact>.self)
    }
    
    @discardableResult
    public func addContacts(contacts: [CreateContact]) async throws -> EmptyResposne {
        let response = try await client.post(buildUri(path: "/contacts/create_many"),
                                             headers: commonHeaders,
                                             content: contacts)
        return try response.content.decode(EmptyResposne.self)
    }
    
    public func updateContact(contact: UpdateContact) async throws -> DataResposne<Contact> {
        let response = try await client.post(buildUri(path: "/contacts/update"),
                                             headers: commonHeaders,
                                             content: contact)
        return try response.content.decode(DataResposne<Contact>.self)
    }
    
    @discardableResult
    public func deleteContact(email: String) async throws -> EmptyResposne {
        
        struct Payload: Content {
            var email: String
        }
        
        let response = try await client.post(buildUri(path: "/contacts/delete"),
                                             headers: commonHeaders,
                                             content: Payload(email: email))
        
        return try response.content.decode(EmptyResposne.self)
    }
    
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
