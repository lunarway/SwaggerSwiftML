import XCTest
import Foundation
import Yams
@testable import SwaggerSwiftML

class ArraySchemaTests: XCTestCase {
    private func load_schema(path: String) -> Schema {
        let basicFileUrl = Bundle.module.url(forResource: path, withExtension: "yaml")

        let fileContents = try! String(contentsOf: basicFileUrl!, encoding: .utf8)

        return try! YAMLDecoder().decode(Schema.self, from: fileContents)
    }

    func testParseArray() {
        let schema = load_schema(path: "Schemas/arrays/array")
        if case let SchemaType.array(items, collectionFormat: _, maxItems: _, minItems: _, uniqueItems: _) = schema.type {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
}
