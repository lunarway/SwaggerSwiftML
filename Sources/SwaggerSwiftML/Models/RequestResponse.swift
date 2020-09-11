public struct RequestResponse: Decodable {
    public let description: String?
    /// Used to tell the code generator what to call the method
    public let operationId: String?
    public let deprecated: Bool?
    public let schema: NodeWrapper<Schema>?

    enum CodingKeys: String, CodingKey {
        case description
        case schema
        case operationId
        case deprecated
    }
}
