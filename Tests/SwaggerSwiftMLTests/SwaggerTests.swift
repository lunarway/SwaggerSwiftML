import XCTest
import Foundation
import Yams
@testable import SwaggerSwiftML

class SwaggerTests: XCTestCase {
    func testParsePrimitiveSchema() {
        let basicFileUrl = Bundle.module.url(forResource: "Swagger/swagger_spec", withExtension: "yaml")

        let fileContents = try! String(contentsOf: basicFileUrl!, encoding: .utf8)

        _ = try! YAMLDecoder().decode(Swagger.self, from: fileContents)
    }
}
