public struct Items: Decodable {
    public let type: ParameterType?

    enum CodingKeys: String, CodingKey {
        case type
        case format
        case items
        case collectionFormat
        case defaultValue = "default"
        case maximum
        case exclusiveMaximum
        case minimum
        case exclusiveMinimum
        case maxLength
        case minLength
        case pattern
        case maxItems
        case minItems
        case uniqueItems
        case enumeration = "enum"
        case multipleOf
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let typeString = try container.decodeIfPresent(String.self, forKey: .type) // ParameterType
        let format = try container.decodeIfPresent(DataFormat.self, forKey: .format)

        
        let maximum = try container.decodeIfPresent(Int.self, forKey: .maximum)
        let exclusiveMaximum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMaximum)
        let minimum = try container.decodeIfPresent(Int.self, forKey: .minimum)
        let exclusiveMinimum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMinimum)
        let maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        let minLength = try container.decodeIfPresent(Int.self, forKey: .minLength)
        let pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
        let maxItems = try container.decodeIfPresent(Int.self, forKey: .maxItems)
        let minItems = try container.decodeIfPresent(Int.self, forKey: .minItems)
        let uniqueItems = try container.decodeIfPresent(Bool.self, forKey: .uniqueItems)
        let enumeration = try container.decodeIfPresent([String].self, forKey: .enumeration)
        let multipleOf = try container.decodeIfPresent(Int.self, forKey: .multipleOf)

        switch typeString {
        case "array":
            let collectionFormat = (try container.decodeIfPresent(CollectionFormat.self, forKey: .collectionFormat)) ?? .csv
            let items = try container.decode(Items.self, forKey: .items)
            self.type = .array(items, collectionFormat: collectionFormat, maxItems: maxItems, minItems: minItems, uniqueItems: uniqueItems ?? false)
        case "boolean":
            self.type = .boolean
        case "file":
            self.type = .file
        case "integer":
            self.type = .integer(format: format, maximum: maximum, exclusiveMaximum: exclusiveMaximum, minimum: minimum, exclusiveMinimum: exclusiveMinimum, multipleOf: multipleOf)
        case "number":
            self.type = .number(format: format, maximum: maximum, exclusiveMaximum: exclusiveMaximum, minimum: minimum, exclusiveMinimum: exclusiveMinimum, multipleOf: multipleOf)
        case "string":
            self.type = .string(format: format, enumValues: enumeration, maxLength: maxLength, minLength: minLength, pattern: pattern)
        default:
            throw SwaggerParseError.invalidField(typeString ?? "No field found on Items")
        }
    }
}
