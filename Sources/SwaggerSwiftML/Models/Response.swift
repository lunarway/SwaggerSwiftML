public struct Response: Decodable {
    public let description: String?
    public let schema: Node<Schema>?
    public let headers: [HeaderObject]?

    enum CodingKeys: String, CodingKey {
        case description
        case schema
        case headers
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.schema = try container.decodeIfPresent(NodeWrapper<Schema>.self, forKey: .schema)?.value

        if container.contains(.headers) {
            let headerKeysContainer = try container.nestedContainer(keyedBy: RawCodingKeys.self, forKey: .headers)

            self.headers = try headerKeysContainer.allKeys.map {
                try headerKeysContainer.decode(HeaderObject.self, forKey: $0)
            }
        } else {
            self.headers = nil
        }
    }
}
