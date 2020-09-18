// Describes a single response from an API Operation.
public struct RequestResponse: Decodable {
    // A short description of the response
    public let description: String?
    /// A definition of the response structure. It can be a primitive, an array or an object. If this field does not exist, it means no content is returned as part of the
    /// response. As an extension to the Schema Object, its root type value may also be "file". This SHOULD be accompanied by a relevant produces mime-type.
    public let schema: NodeWrapper<Schema>?
    // A list of headers that are sent with the response.
    public let headers: [String: Header]?
}
