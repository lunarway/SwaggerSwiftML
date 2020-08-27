public struct NodeWrapper<T: Decodable> {
    public let value: Node<T>
}

extension NodeWrapper: Decodable {
    public init (from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let ref = try? container.decode(Reference.self) {
            value = .reference(ref.ref)
        } else if let prop = try? container.decode(T.self) {
            value = .node(prop)
        } else {
            fatalError("Failed to parse: \(container)")
        }
    }
}
