import XCTest
import Foundation
import Yams
@testable import SwaggerSwiftML

class DictionarySchemaTests: XCTestCase {
    private func load_schema(path: String) -> Schema {
        let basicFileUrl = Bundle.module.url(forResource: path, withExtension: "yaml")

        let fileContents = try! String(contentsOf: basicFileUrl!, encoding: .utf8)

        return try! YAMLDecoder().decode(Schema.self, from: fileContents)
    }

    func testParseStringToStringDictionary() {
        let schema = load_schema(path: "Schemas/Dictionary/simple_dictionary")
        if case let SchemaType.dictionary(valueType: valueType, _) = schema.type {
            if case let DictionaryValueType.schema(schema) = valueType {
                if case SchemaType.string = schema.type {
                    XCTAssert(true)
                    return
                }
            }
        }

        XCTAssert(false)
    }

    func testParseRequiredKeysDictionary() {
        let schema = load_schema(path: "Schemas/Dictionary/dict_fixed_keys")

        // verify that the value type is a string
        if case let SchemaType.dictionary(valueType: valueType, _) = schema.type {
            if case let DictionaryValueType.schema(schema) = valueType {
                if case SchemaType.string = schema.type {
                    XCTAssert(true)
                } else { XCTAssert(false) }
            } else { XCTAssert(false) }
        } else { XCTAssert(false) }

        if case let SchemaType.dictionary(_, requiredKeys) = schema.type {
            XCTAssertEqual(requiredKeys.count, 1)
            if (requiredKeys.count == 0) {
                XCTAssert(false, "Failed to find any required keys")
                return
            }

            let key = requiredKeys[0]
            XCTAssertEqual(key.name, "default")
            XCTAssertNotNil(key.type)
            XCTAssertTrue(key.required)
        } else { XCTAssert(false) }
    }

    func testParseFreeformBooleanDictionary() {
        let schema = load_schema(path: "Schemas/Dictionary/dict_freeform_boolean")

        // verify that the value type is a string
        if case let SchemaType.dictionary(valueType: valueType, _) = schema.type {
            if case DictionaryValueType.any = valueType {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        } else { XCTAssert(false) }
    }

    func testParseFreeformEmptyObjectDictionary() {
        let schema = load_schema(path: "Schemas/Dictionary/dict_freeform_empty_object")

        // verify that the value type is a string
        if case let SchemaType.dictionary(valueType: valueType, _) = schema.type {
            if case DictionaryValueType.any = valueType {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        } else { XCTAssert(false) }
    }

    func testParseValueIsInlineObjectDictionary() {
        let schema = load_schema(path: "Schemas/Dictionary/dict_value_is_inline_schema")

        // verify that the value type is a string
        if case let SchemaType.dictionary(valueType: valueType, _) = schema.type {
            if case let DictionaryValueType.schema(schema) = valueType {
                if case let SchemaType.object(properties: props) = schema.type {
                    let codeProp = props["code"]!.value.unwrapped!

                    if case SchemaType.integer = codeProp.type {
                        XCTAssert(true)
                    } else { XCTAssert(false) }

                    let textProp = props["text"]!.value.unwrapped!

                    if case SchemaType.string = textProp.type {
                        XCTAssert(true)
                    } else { XCTAssert(false) }
                }
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        } else { XCTAssert(false) }
    }

    func testParseValueIsInlineReferenceDictionary() {
        let schema = load_schema(path: "Schemas/Dictionary/dict_value_is_reference")

        // verify that the value type is a string
        if case let SchemaType.dictionary(valueType: valueType, _) = schema.type {
            if case let DictionaryValueType.reference(ref) = valueType {
                XCTAssertEqual(ref, "#/components/schemas/Message")
            } else {
                XCTAssert(false)
            }
        } else { XCTAssert(false) }
    }
}

extension SwaggerSwiftML.Node {
    var unwrapped: T? {
        switch self {
        case .node(let node): return node
        case .reference: return nil
        }
    }
}
