/// Represents a response returning data.
public struct DataResponse<T: Codable & Sendable>: Codable, Sendable {

    public init(data: T) {
        self.success = true
        self.data = data
    }

    /// Always true
    public var success: Bool

    /// Returned data
    public var data: T
}

/// Represents a response returning no useful data.
public struct EmptyResposne: Codable, Sendable {

    public init() {
        self.success = true
    }

    /// Always true
    public var success: Bool
}

/// Represents a response returning paginated data.
public struct PagedDataResponse<T: Codable & Sendable>: Codable, Sendable {
    public init(data: [T], metadata: PagedDataResponse<T>.PageMetadata) {
        self.success = true
        self.data = data
        self.metadata = metadata
    }

    /// Paging metadata
    public struct PageMetadata: Codable, Sendable {
        public init(page: Int, per: Int, total: Int) {
            self.page = page
            self.per = per
            self.total = total
        }

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
    public var data: [T]

    /// Paging metadata
    public var metadata: PageMetadata
}

struct ErrorResponse: Codable, Sendable {
    var reason: String
    var error: Bool
}
