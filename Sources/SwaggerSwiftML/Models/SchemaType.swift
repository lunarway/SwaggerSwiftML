/// Schema types
public indirect enum SchemaType {
    case string(format: DataFormat?, enumValues: [String]?, maxLength: Int?, minLength: Int?, pattern: String?)
    case number(format: DataFormat?, maximum: Int?, exclusiveMaximum: Bool?, minimum: Int?, exclusiveMinimum: Bool?, multipleOf: Int?)
    case integer(format: DataFormat?, maximum: Int?, exclusiveMaximum: Bool?, minimum: Int?, exclusiveMinimum: Bool?, multipleOf: Int?)
    case boolean
    case array(Node<Items>, collectionFormat: CollectionFormat, maxItems: Int?, minItems: Int?, uniqueItems: Bool)
    case object(properties: [String: Node<Schema>], allOf: [Node<Schema>]?)

    // The schema represents a dictionary type, i.e. a [String: <something>]
    // - valueType: the value type of the dictionary, i.e. the `something`
    // - requiredKeys: if there are any keys that are required to be filled out in the object they are defined here
    case dictionary(valueType: DictionaryValueType, keys: [KeyType])
}
