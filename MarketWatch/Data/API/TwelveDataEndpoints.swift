enum TwelveDataEndpoints {
    static func quote(symbol: String) -> String { "/quote" }
    static let timeSeries = "/time_series"
    static let symbolSearch = "/symbol_search"
}
