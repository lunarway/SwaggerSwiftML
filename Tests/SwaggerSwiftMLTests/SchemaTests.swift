import XCTest
import Foundation
import Yams
@testable import SwaggerSwiftML

class SchemaTests: XCTestCase {
    func testParsePrimitiveSchema() {
        let basicFileUrl = Bundle.module.url(forResource: "Schemas/PrimitiveSchema", withExtension: "yaml")

        let fileContents = try! String(contentsOf: basicFileUrl!, encoding: .utf8)

        let schema = try! YAMLDecoder().decode(Schema.self, from: fileContents)

        switch schema.type {
        case .string(let format, enumValues: _, maxLength: _, minLength: _, pattern: _):
            XCTAssertNotNil(format)
            XCTAssertEqual(format!, .email)
        default:
            XCTAssert(false)
        }
    }

    func testParseSimpleModel() {
        let basicFileUrl = Bundle.module.url(forResource: "Schemas/simple_model", withExtension: "yaml")

        let fileContents = try! String(contentsOf: basicFileUrl!, encoding: .utf8)

        let schema = try! YAMLDecoder().decode(Schema.self, from: fileContents)

        switch schema.type {
        case .object(let properties):
            XCTAssertTrue(true)
            let nameProperty = properties["name"]!
            XCTAssertNotNil(nameProperty)
            switch nameProperty.value {
            case .reference:
                XCTAssert(false, "should not find a reference")
            case .node(let property):
                guard let type = property.type else {
                    XCTAssert(false)
                    return
                }

                switch type {
                case .string(format: let format, enumValues: let enumValues, maxLength: let maxLength, minLength: let minLength, pattern: let pattern):
                    XCTAssertNil(format)
                    XCTAssertNil(enumValues)
                    XCTAssertNil(maxLength)
                    XCTAssertNil(minLength)
                    XCTAssertNil(pattern)
                default:
                    XCTAssert(false, "Found type: \(type)")
                }
            }

            let addressProperty = properties["address"]!
            XCTAssertNotNil(addressProperty)
            switch addressProperty.value {
            case .reference(let ref):
                XCTAssertEqual(ref, "#/definitions/Address")
            default:
                XCTAssert(false)
            }

            let ageProperty = properties["age"]!
            XCTAssertNotNil(ageProperty)
            switch ageProperty.value {
            case .reference:
                XCTAssert(false, "should not find a reference")
            case .node(let property):
                guard let type = property.type else {
                    XCTAssert(false)
                    return
                }

                switch type {
                case .integer(format: let format, maximum: let maximum, exclusiveMaximum: let exclusiveMaximum, minimum: let minimum, exclusiveMinimum: let exclusiveMinimum, multipleOf: let multipleOf):
                    XCTAssertNotNil(format)
                    XCTAssertEqual(format!, .int32)
                    XCTAssertEqual(minimum!, 0)
                    XCTAssertNil(maximum)
                    XCTAssertNil(multipleOf)
                    XCTAssertNil(exclusiveMinimum)
                    XCTAssertNil(exclusiveMaximum)
                default:
                    XCTAssert(false, "Found type: \(type)")
                }
            }
        default:
            XCTAssert(false)
        }
    }
}
