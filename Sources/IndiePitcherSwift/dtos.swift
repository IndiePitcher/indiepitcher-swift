//
//  File.swift
//  
//
//  Created by Petr Pavlik on 17.08.2024.
//

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

/// Represents a contact list contacts can subscribe to, such as `Monthly newsletter` or `Onboarding`.
public struct ContactList: Content {
    
    public init(id: UUID, name: String, title: String, numSubscribers: Int) {
        self.id = id
        self.name = name
        self.title = title
        self.numSubscribers = numSubscribers
    }
    
    public var id: UUID
    public var name: String
    public var title: String
    public var numSubscribers: Int
}

public struct ContactListPortalSession: Content {
    public init(id: UUID, url: URL, expiresAt: Date, returnURL: URL) {
        self.id = id
        self.url = url
        self.expiresAt = expiresAt
        self.returnURL = returnURL
    }
    
    public var id: UUID
    public var url: URL
    public var expiresAt: Date
    public var returnURL: URL
}
