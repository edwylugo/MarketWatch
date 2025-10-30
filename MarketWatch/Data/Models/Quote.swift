struct Quote: Decodable, Equatable {
    let symbol: String
    let name: String?
    let price: Double
    let changePercent: Double?
    let previousClose: Double?

    enum CodingKeys: String, CodingKey {
        case symbol, name, price
        case changePercent = "percent_change"
        case previousClose = "previous_close"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try c.decode(String.self, forKey: .symbol)
        name = try? c.decode(String.self, forKey: .name)
        price = try c.decodeStringOrDouble(forKey: .price) ?? 0
        changePercent = try c.decodeStringOrDouble(forKey: .changePercent)
        previousClose = try c.decodeStringOrDouble(forKey: .previousClose)
    }

    init(
        symbol: String,
        name: String?,
        price: Double,
        changePercent: Double?,
        previousClose: Double?
    ) {
        self.symbol = symbol
        self.name = name
        self.price = price
        self.changePercent = changePercent
        self.previousClose = previousClose
    }
}
