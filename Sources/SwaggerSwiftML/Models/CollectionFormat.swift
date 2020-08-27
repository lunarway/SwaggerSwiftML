public enum CollectionFormat: String, Codable {
    case csv
    case ssv
    case tsv
    case pipes
}

extension CollectionFormat: Equatable { }
