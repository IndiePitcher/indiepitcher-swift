import XCTest
@testable import IndiePitcherSwift
import AsyncHTTPClient
import Nimble

final class IndiePitcherSwiftTests: XCTestCase {
    
    var indiePitcher: IndiePitcher!
    
    override func setUp() async throws {
        indiePitcher = IndiePitcher(apiKey: IP_SECRET_API_KEY)
    }
    
    override func tearDown() async throws {
        // work around API rate limiting
        try await Task.sleep(for: .seconds(1))
    }
    
    func testThrowRequestError() async {
        let indiePitcherx = IndiePitcher(apiKey: "fake")
        await expect({try await indiePitcherx.listMailingLists()})
            .to(throwError(IndiePitcherRequestError(statusCode: 401, reason: "Unauthorized")))
    }
    
    func testSendTransactionalEmailMarkdown() async throws {
        
        try await indiePitcher.sendEmail(data: .init(to: "petr@example.com",
                                           subject: "Test email from IP Swift SDK unit tests",
                                           body: "This is a test body that supports **markdown**.",
                                           bodyFormat: .markdown))
    }
    
    func testGetMailingLists() async throws {
        let listsResponse = try await indiePitcher.listMailingLists()
        expect(listsResponse.metadata.total) == 3
        expect(listsResponse.data.count) == 3
    }
    
    func testSendMarketingEmailToList() async throws {
        try await indiePitcher.sendEmailToMailingList(data: .init(subject: "Test marketing email from IP Swift SDK unit tests",
                                                        body: "This is a test body of a marketing email that supports **markdown**.",
                                                        bodyFormat: .markdown,
                                                        list: "integration-tests"))
    }
    
    func testSendEmailToContact() async throws {
        try await indiePitcher.sendEmailToContact(data: .init(contactEmail: "petr@example.com",
                                                              subject: "Test personalized contact email from IP Swift SDK unit tests",
                                                              body: "This is a test body of a personalized transactional email that supports **markdown**.",
                                                              bodyFormat: .markdown,
                                                              list: "integration-tests",
                                                              delaySeconds: 60))
    }
    
    func testContactManagement() async throws {
        let email = "test@example.com"
        try await indiePitcher.addContact(contact: .init(email: email,
                                                         subscribedToLists: ["test_list_1", "test_list_2"]))

        try await indiePitcher.deleteContact(email: email)
    }
    
    func testAddMultipleContacts() async throws {
        
        try await indiePitcher.addContacts(contacts: [.init(email: "test@example.com"), .init(email: "test2@example.com")])
        try await indiePitcher.deleteContact(email: "test@example.com")
        try await indiePitcher.deleteContact(email: "test2@example.com")
    }
    
    func testCreatePortalSession() async throws {
        _ = try await indiePitcher.createMailingListsPortalSession(contactEmail: "petr@indiepitcher.com", returnURL: .init(string: "https://indiepitcher.com")!)
    }
}
