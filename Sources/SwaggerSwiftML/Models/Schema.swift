public enum DictionaryValueType {
    case any
    case reference(String)
    case schema(Schema)
}

/// Schema types
public indirect enum SchemaType {
    case string(format: DataFormat?, enumValues: [String]?, maxLength: Int?, minLength: Int?, pattern: String?)
    case number(format: DataFormat?, maximum: Int?, exclusiveMaximum: Bool?, minimum: Int?, exclusiveMinimum: Bool?, multipleOf: Int?)
    case integer(format: DataFormat?, maximum: Int?, exclusiveMaximum: Bool?, minimum: Int?, exclusiveMinimum: Bool?, multipleOf: Int?)
    case boolean
    case array(Node<Items>, collectionFormat: CollectionFormat, maxItems: Int?, minItems: Int?, uniqueItems: Bool)
    case object(properties: [String: NodeWrapper<Schema>])

    // The schema represents a dictionary type, i.e. a [String: <something>]
    // - valueType: the value type of the dictionary, i.e. the `something`
    // - requiredKeys: if there are any keys that are required to be filled out in the object they are defined here
    case dictionary(valueType: DictionaryValueType, keys: [KeyType])
}

public struct KeyType {
    let name: String
    let type: Schema
    let required: Bool
}

private struct EmptyObject: Codable {

}

public struct Schema: Decodable {
    public let title: String?
    public let description: String?
    public let uniqueItems: Bool
    public let maxProperties: Int?
    public let minProperties: Int?
    public let required: [String]
    public let type: SchemaType
//    public let allOf: [NodeWrapper<Schema>]?

    enum CodingKeys: String, CodingKey {
        case format
        case title
        case description
        case multipleOf
        case maximum
        case exclusiveMaximum
        case minimum
        case excluesiveMinimum
        case maxLength
        case minLength
        case pattern
        case maxItems
        case minItems
        case uniqueItems
        case maxProperties
        case minProperties
        case required
        case enumeration = "enum"
        case type
        case items
        case allOf
        case properties
        case additionalProperties
        case collectionFormat
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let format = try container.decodeIfPresent(DataFormat.self, forKey: .format)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        let multipleOf = try container.decodeIfPresent(Int.self, forKey: .multipleOf)
        let maximum = try container.decodeIfPresent(Int.self, forKey: .maximum)
        let exclusiveMaximum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMaximum)
        let minimum = try container.decodeIfPresent(Int.self, forKey: .minimum)
        let excluesiveMinimum = try container.decodeIfPresent(Bool.self, forKey: .excluesiveMinimum)
        let maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        let minLength = try container.decodeIfPresent(Int.self, forKey: .minLength)
        let pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
        let maxItems = try container.decodeIfPresent(Int.self, forKey: .maxItems)
        let minItems = try container.decodeIfPresent(Int.self, forKey: .minItems)
        self.uniqueItems = (try container.decodeIfPresent(Bool.self, forKey: .uniqueItems)) ?? false
        self.maxProperties = try container.decodeIfPresent(Int.self, forKey: .maxProperties)
        self.minProperties = try container.decodeIfPresent(Int.self, forKey: .minProperties)
        self.required = (try container.decodeIfPresent([String].self, forKey: .required)) ?? []
        let enumeration = try container.decodeIfPresent([String].self, forKey: .enumeration)

        var typeString = try container.decodeIfPresent(String.self, forKey: .type)
        if typeString == nil {
            if container.contains(.properties) {
                typeString = "object"
            } else {
                throw SwaggerError.failedToParse
            }
        }

        guard typeString != nil else { fatalError("Failed to find type on schema") }

        switch typeString! {
        case "object":
            let isDictionary = container.contains(.additionalProperties)
            let properties = (try? container.decodeIfPresent([String: Schema].self, forKey: .properties)) ?? [:]
            let required = (try container.decodeIfPresent([String].self, forKey: .required)) ?? []

            let keys = properties.map { prop in
                KeyType(name: prop.key,
                        type: prop.value,
                        required: required.contains(prop.key))
            }

            if isDictionary {
                if let reference = try? container.decodeIfPresent(Reference.self, forKey: .additionalProperties) {
                    self.type = .dictionary(valueType: .reference(reference.ref), keys: keys)
                } else if let schema = try? container.decodeIfPresent(Schema.self, forKey: .additionalProperties) {
                    self.type = .dictionary(valueType: .schema(schema), keys: keys)
                } else if let boolValue = try? container.decodeIfPresent(Bool.self, forKey: .additionalProperties) {
                    guard boolValue == true else { fatalError("additionalProperties set to false doesnt have any meaning") }
                    self.type = .dictionary(valueType: .any, keys: keys)
                } else {
                    self.type = .dictionary(valueType: .any, keys: keys)
                }
            } else {
                let properties = try container.decodeIfPresent([String: NodeWrapper<Schema>].self, forKey: .properties)
                self.type = .object(properties: properties ?? [:])
            }
        case "string":
            self.type = .string(format: format, enumValues: enumeration, maxLength: maxLength, minLength: minLength, pattern: pattern)
        case "number":
            self.type = .number(format: format, maximum: maximum, exclusiveMaximum: exclusiveMaximum, minimum: minimum, exclusiveMinimum: excluesiveMinimum, multipleOf: multipleOf)
        case "integer":
            self.type = .integer(format: format, maximum: maximum, exclusiveMaximum: exclusiveMaximum, minimum: minimum, exclusiveMinimum: excluesiveMinimum, multipleOf: multipleOf)
        case "boolean":
            self.type = .boolean
        case "array":
            let uniqueItems = (try container.decodeIfPresent(Bool.self, forKey: .uniqueItems) ?? false)
            let collectionFormat = (try container.decodeIfPresent(CollectionFormat.self, forKey: .collectionFormat)) ?? .csv

            let node: Node<Items>
            if let itemsObject = try? container.decode(Items.self, forKey: .items) {
                node = .node(itemsObject)
            } else if let ref = try? container.decode(Reference.self, forKey: .items) {
                node = .reference(ref.ref)
            } else {
                throw SwaggerError.corruptFile
            }

            self.type = .array(node, collectionFormat: collectionFormat, maxItems: maxItems, minItems: minItems, uniqueItems: uniqueItems)
        default:
            throw SchemaParseError.invalidType("Unsupported type: \(typeString!) found on a schema")
        }
//        self.items = container.decodeIfPresent(String.self, forKey: .items)
//        self.allOf = container.decodeIfPresent(String.self, forKey: .allOf)
//        self.properties = container.decodeIfPresent(String.self, forKey: .properties)
//        self.additionalProperties = container.decodeIfPresent(Bool.self, forKey: .additionalProperties)
    }
}

enum SchemaParseError: Error {
    case invalidType(String)
}
