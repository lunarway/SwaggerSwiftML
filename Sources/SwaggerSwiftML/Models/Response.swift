public struct Response: Decodable {
    public let description: String?
    public let schema: Node<Schema>?

    enum CodingKeys: String, CodingKey {
        case description
        case schema
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.schema = try container.decodeIfPresent(NodeWrapper<Schema>.self, forKey: .schema)?.value
    }
}
