public struct Response: Decodable {
    public let description: String?
    public let schema: Node<Schema>?
    public let headers: [String: HeaderObject]?

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

            var headers = [String: HeaderObject]()
            try headerKeysContainer.allKeys.map {
                ($0.stringValue, try headerKeysContainer.decode(HeaderObject.self, forKey: $0))
            }.forEach { headers[$0] = $1 }

            self.headers = headers
        } else {
            self.headers = nil
        }
    }
}
