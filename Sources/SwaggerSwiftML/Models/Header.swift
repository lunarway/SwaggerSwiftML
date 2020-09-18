public enum HeaderType: String, Decodable {
    case string
//    case number
//    case integer
//    case boolean
//    case array
}

public struct Header: Decodable {
    let description: String?
    let type: HeaderType // TODO: Lots of types are not supported atm https://swagger.io/specification/v2/#headerObject
}
