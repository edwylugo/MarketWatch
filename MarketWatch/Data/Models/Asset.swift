struct Asset: Decodable, Equatable {
    let symbol: String
    let name: String
    let currency: String?
}
