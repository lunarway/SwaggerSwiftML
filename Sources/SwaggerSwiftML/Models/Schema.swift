public struct Schema: Decodable {
    public let title: String?
    public let description: String?
    public let uniqueItems: Bool
    public let maxProperties: Int?
    public let minProperties: Int?
    public let required: [String]
    public let type: SchemaType
    public let customFields: [String: String]

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

    private struct CustomCodingKeys: CodingKey {
        var intValue: Int?
        var stringValue: String

        init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
        init?(stringValue: String) { self.stringValue = stringValue }

        static func make(key: String) -> CodingKeys {
            return CodingKeys(stringValue: key)!
        }
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

        let unknownKeysContainer = try decoder.container(keyedBy: RawCodingKeys.self)
        let keys = unknownKeysContainer.allKeys.filter { $0.stringValue.starts(with: "x-", by: { $0 == $1  }) }

        var customFields = [String: String]()
        keys.map { ($0.stringValue, try? unknownKeysContainer.decode(String.self, forKey: $0)) }
        .forEach { key, value in customFields[key] = value }
        self.customFields = customFields

        var typeString = try container.decodeIfPresent(String.self, forKey: .type)
        if typeString == nil {
            if container.contains(.properties) {
                typeString = "object"
            } else {
                throw SwaggerError.failedToParse
            }
        }

        guard let type = typeString else { fatalError("Failed to find type on schema") }

        switch type {
        case "object":
            // A dictionary in swagger is always String indexed, and is defined by having the additionalProperties field.
            // The additional properties field must have a child defining the value type of the dictionary.
            // See https://swagger.io/docs/specification/data-models/dictionaries/

            var isFreeFormObject = false
            var isDictionary = false
            if container.contains(.additionalProperties) {
                // if .additionalProperties is defined and set to true then this is a freeform object
                if let boolValue = try? container.decode(Bool.self, forKey: .additionalProperties), boolValue == true {
                    isFreeFormObject = true
                }

                if let additionalPropertiesContainer = try? container.nestedContainer(keyedBy: CustomCodingKeys.self, forKey: .additionalProperties) {
                    let count = additionalPropertiesContainer.allKeys.count

                    // if .additionalProperties is defined but it has no children then it means that this is a free
                    // form object, if it should have been a dictionary the value type would have to be defined
                    // under .additionalProperties
                    if count == 0 {
                        isFreeFormObject = true
                    } else if count > 0 {
                        isDictionary = true
                    }
                }
            }

            if let unkeyed = try? decoder.container(keyedBy: CustomCodingKeys.self) {
                if unkeyed.allKeys.count == 1 && unkeyed.allKeys.contains(where: { $0.stringValue == "type" }) {
                    isFreeFormObject = true
                } else if unkeyed.allKeys.count == 0 {
                    isFreeFormObject = true
                }
            }

            if isFreeFormObject {
                self.type = .dictionary(valueType: .any, keys: [])
                return
            }

            if isDictionary {
                let properties = (try? container.decodeIfPresent([String: Schema].self, forKey: .properties)) ?? [:]
                let required = (try container.decodeIfPresent([String].self, forKey: .required)) ?? []

                let keys = properties.map { KeyType(name: $0.key, type: $0.value, required: required.contains($0.key)) }

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
                if isFreeFormObject {
                    self.type = .freeform
                } else {
                    let allOf = try container.decodeIfPresent([NodeWrapper<Schema>].self, forKey: .allOf).map { $0.map { $0.value } }

                    let properties = try container.decodeIfPresent([String: NodeWrapper<Schema>].self, forKey: .properties)?
                        .compactMapValues { $0.value }

                    self.type = .object(properties: properties ?? [:], allOf: allOf)
                }
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

            self.type = .array(node,
                               collectionFormat: collectionFormat,
                               maxItems: maxItems,
                               minItems: minItems,
                               uniqueItems: uniqueItems)
        case "file":
            self.type = .file
        default:
            throw SchemaParseError.invalidType("Unsupported type: \(typeString!) found on a schema")
        }
    }
}

enum SchemaParseError: Error {
    case invalidType(String)
}
