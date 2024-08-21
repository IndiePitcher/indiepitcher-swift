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

/// Represents a custom contact property.
public enum CustomContactPropertyValue: Codable, Equatable {
    /// A string property
    case string(String)
    /// A number property
    case number(Double)
    /// A boolean property
    case bool(Bool)
    /// A date property
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
    /// The array of mailing lists the contact is subscribed to.
    public var subscribedToLists: [String]
    /// The custom properties set fort his contact.
    public var customProperties: [String: CustomContactPropertyValue]
    /// The primary language language of this contact, represented by a language code. Example: en-US
    public var languageCode: String?
}

/// The payload to create a new contact
public struct CreateContact: Content {
    
    /// Initializer
    /// - Parameters:
    ///   - email: The email of the contact.
    ///   - userId: The user id of the contact.
    ///   - avatarUrl: The avatar url of the contact.
    ///   - name: The full name of the contact.
    ///   - languageCode: The language code of the contact.
    ///   - updateIfExists: If a contact with the provided email already exists, update the contact with the new data.
    ///   - subscribedToLists: The list of mailing lists the contact should be subscribed to. Use the `name` field of the lists.
    ///   - customProperties: The custom properties of the contact. Custom properties must be first defined in the IndiePitcher dashboard.
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
    
    /// The email of the contact.
    public var email: String
    /// The user id of the contact.
    public var userId: String?
    /// The avatar url of the contact.
    public var avatarUrl: String?
    /// The full name of the contact.
    public var name: String?
    /// The language code of the contact.
    public var languageCode: String?
    /// If a contact with the provided email already exists, update the contact with the new data.
    public var updateIfExists: Bool?
    /// The list of mailing lists the contact should be subscribed to. Use the `name` field of the lists.
    public var subscribedToLists: Set<String>?
    /// The custom properties of the contact. Custom properties must be first defined in the IndiePitcher dashboard.
    public var customProperties: [String: CustomContactPropertyValue]?
}

/// The payload to create multiple contacts using a single API call
public struct CreateMultipleContacts: Content {
    
    /// Initializer
    /// - Parameter contacts: The list of contacts to create
    public init(contacts: [CreateContact]) {
        self.contacts = contacts
    }
    
    /// The list of contacts to create
    public var contacts: [CreateContact]
}

/// The payload to update a contact in the contact list. The email is required to identify the contact.
public struct UpdateContact: Content {
    
    /// Initializer
    /// - Parameters:
    ///   - email: The email of the contact.
    ///   - userId: The user id of the contact.
    ///   - avatarUrl: The avatar url of the contact.
    ///   - name: The full name of the contact.
    ///   - languageCode: The language code of the contact.
    ///   - addedListSubscripitons: The list of mailing lists to subscribe the contact to. Use the `name` field of the lists.
    ///   - removedListSubscripitons: The list of mailing lists unsubscribe the contact from. Use the `name` field of the lists.
    ///   - customProperties: The custom properties of the contact. Custom properties must be first defined in the IndiePitcher dashboard. Pass 'nil' to remove a custom property.
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
    
    /// The email of the contact.
    public var email: String
    /// The user id of the contact.
    public var userId: String?
    /// The avatar url of the contact.
    public var avatarUrl: String?
    /// The full name of the contact.
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

/// Payload of send transactional email request.
public struct SendEmail: Content {
    
    /// Initializer
    /// - Parameters:
    ///   - to: Can be just an email "john@example.com", or an email with a neme "John Doe <john@example.com>"
    ///   - subject: The subject of the email.
    ///   - body: The body of the email.
    ///   - bodyFormat: The format of the body of the email. Can be `markdown` or `html`.
    public init(to: String, subject: String, body: String, bodyFormat: EmailBodyFormat) {
        self.to = to
        self.subject = subject
        self.body = body
        self.bodyFormat = bodyFormat
    }
    
    /// Can be just an email "john@example.com", or an email with a neme "John Doe <john@example.com>"
    public var to: String
    
    /// The subject of the email.
    public var subject: String
    
    /// The body of the email.
    public var body: String
    
    /// The format of the body of the email. Can be `markdown` or `html`.
    public var bodyFormat: EmailBodyFormat
}

/// Send an email to one of more registered contacts.
public struct SendEmailToContact: Content {
    
    /// Initializer
    /// - Parameters:
    ///   - contactEmail: The email of the contact to send.
    ///   - contactEmails: Allows you to send an email to multiple contacts using a single request.
    ///   - subject: The subject of the email. Supports personalization.
    ///   - body: The body of the email. Both HTML and markdown body do support personalization.
    ///   - bodyFormat: The format of the body of the email. Can be `markdown` or `html`.
    ///   - list: Specify a list the contact(s) can unsubscribe from if they don't wish to receive further emails like this. The contact(s) must be subscribed to this list. Pass "important" to provide a list the contact(s) cannot unsubscribe from.
    ///   - delaySeconds: Delay sending of this email by the amount of seconds you provide.
    ///   - delayUntilDate: Delay sending of this email until specified date.
    public init(contactEmail: String? = nil, contactEmails: [String]? = nil, subject: String, body: String, bodyFormat: EmailBodyFormat, list: String = "important", delaySeconds: TimeInterval? = nil, delayUntilDate: Date? = nil) {
        self.contactEmail = contactEmail
        self.contactEmails = contactEmails
        self.subject = subject
        self.body = body
        self.bodyFormat = bodyFormat
        self.list = list
        self.delaySeconds = delaySeconds
        self.delayUntilDate = delayUntilDate
    }
    
    /// The email of the contact to send.
    public var contactEmail: String?
    
    /// Allows you to send an email to multiple contacts using a single request.
    public var contactEmails: [String]?
    
    /// The subject of the email. Supports personalization.
    public var subject: String
    
    /// The body of the email. Both HTML and markdown body do support personalization.
    public var body: String
    
    /// The format of the body of the email. Can be `markdown` or `html`.
    public var bodyFormat: EmailBodyFormat
    
    /// Specify a list the contact(s) can unsubscribe from if they don't wish to receive further emails like this. The contact(s) must be subscribed to this list. Pass "important" to provide a list the contact(s) cannot unsubscribe from.
    public var list: String
    
    /// Delay sending of this email by the amount of seconds you provide.
    public var delaySeconds: TimeInterval?
    
    /// Delay sending of this email until specified date.
    public var delayUntilDate: Date?
}

public struct SendEmailToContactList: Content {
    
    /// Initializer
    /// - Parameters:
    ///   - subject: The subject of the email. Supports personalization.
    ///   - body: The body of the email. Both HTML and markdown body do support personalization.
    ///   - bodyFormat: The format of the body of the email. Can be `markdown` or `html`.
    ///   - list: The email will be sent to contacts subscribed to this list. Pass "important" to send the email to all of your contacts.
    ///   - delaySeconds: Delay sending of this email by the amount of seconds you provide.
    ///   - delayUntilDate: Delay sending of this email by the amount of seconds you provide.
    public init(subject: String, body: String, bodyFormat: EmailBodyFormat, list: String = "important", delaySeconds: TimeInterval? = nil, delayUntilDate: Date? = nil) {
        self.subject = subject
        self.body = body
        self.bodyFormat = bodyFormat
        self.list = list
        self.delaySeconds = delaySeconds
        self.delayUntilDate = delayUntilDate
    }
    
    /// The subject of the email. Supports personalization.
    public var subject: String
    
    /// The body of the email. Both HTML and markdown body do support personalization.
    public var body: String
    
    /// The format of the body of the email. Can be `markdown` or `html`.
    public var bodyFormat: EmailBodyFormat
    
    /// The email will be sent to contacts subscribed to this list. Pass "important" to send the email to all of your contacts.
    public var list: String
    
    /// Delay sending of this email by the amount of seconds you provide.
    public var delaySeconds: TimeInterval?
    
    /// Delay sending of this email until specified date.
    public var delayUntilDate: Date?
}

/// Represents a contact list contacts can subscribe to, such as `Monthly newsletter` or `Onboarding`.
public struct ContactList: Content {
    
    public init(name: String, title: String, numSubscribers: Int) {
        self.name = name
        self.title = title
        self.numSubscribers = numSubscribers
    }
    
    /// The unique name of the contact list meant to be used by the public API. Not intended to be be shown to the end users, that's what `title` is for.
    public var name: String
    
    /// A human readable name of the contact list.
    public var title: String
    
    /// The  number of contacts subscribed to this list.
    public var numSubscribers: Int
}


/// A portal session that allows a contact to manage their email list subscriptions when redirected to returned `url`. A session is valid for 30 minutes.
public struct ContactListPortalSession: Content {
    public init(url: URL, expiresAt: Date, returnURL: URL) {
        self.url = url
        self.expiresAt = expiresAt
        self.returnURL = returnURL
    }
    
    /// The URL under which the user can manage their list subscriptions.
    public var url: URL
    
    /// Specified until when will the URL be valid
    public var expiresAt: Date
    
    /// URL to redirect the user to when they tap on that they're cone editing their lists, or when the session is expired.
    public var returnURL: URL
}
