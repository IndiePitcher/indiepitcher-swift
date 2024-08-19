import XCTest
@testable import IndiePitcherSwift
import Vapor
import Nimble

final class IndiePitcherSwiftTests: XCTestCase {
    
    var app: Application!
    var indiePitcher: IndiePitcher!
    
    override func setUp() async throws {
        app = try await Application.make(.testing)
        indiePitcher = IndiePitcher(client: app.client, apiKey: Environment.get("IP_SECRET_API_KEY")!)
    }
    
    override func tearDown() async throws {
        try await app.asyncShutdown()
    }
    
    func testSendTransactionalEmailMarkdown() async throws {
        
        try await indiePitcher.sendEmail(data: .init(to: "petr@indiepitcher.com",
                                           subject: "Test email from IP Swift SDK unit tests",
                                           body: "This is a test body that supports **markdown**.",
                                           bodyFormat: .markdown))
    }
    
    func testGetContactLists() async throws {
        let listsResponse = try await indiePitcher.listContactLists()
        expect(listsResponse.metadata.total) == 2
        expect(listsResponse.data.count) == 2
    }
    
    func testSendMarketingEmailToList() async throws {
        try await indiePitcher.sendEmailToContactList(data: .init(subject: "Test marketing email from IP Swift SDK unit tests",
                                                        body: "This is a test body of a marketing email that supports **markdown**.",
                                                        bodyFormat: .markdown,
                                                        list: "test_list_1"))
    }
    
    func testSendEmailToContact() async throws {
        try await indiePitcher.sendEmailToContact(data: .init(contactEmail: "petr@indiepitcher.com",
                                                              subject: "Test personalized contact email from IP Swift SDK unit tests",
                                                              body: "This is a test body of a personalized transactional email that supports **markdown**.",
                                                              bodyFormat: .markdown,
                                                              list: "test_list_1",
                                                              delaySeconds: 60))
    }
    
    func testContactManagement() async throws {
        let email = "test@example.com"
        try await indiePitcher.addContact(contact: .init(email: email,
                                                         subscribedToLists: ["test_list_1", "test_list_2"]))

        try await indiePitcher.deleteContact(email: email)
    }
}
