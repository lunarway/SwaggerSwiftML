import SwaggerSwiftML
import Testing

struct DefinitionTest {
    @Test func testStuff() async throws {
        let text = """
            info:
              title: API
              description: Exposes relevant endpoints
              version: 1.0.0
              contact:
                url: "https://swift.app/"

            paths:
                /endpoint:
                    get:
                      responses:
                        200:
                          description: Successful response
                          schema:
                            $ref: '#/definitions/Create'
            definitions:
              Create:
                type: object
                $ref: '#/definitions/Stuff'

              Stuff:
                type: object
                properties:
                  id:
                    type: string
            """

        let swagger = try SwaggerReader.read(text: text)
        let createSchema = swagger.definitions?.first(where: { $0.key == "Create" })?.value
    }
}
