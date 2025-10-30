import RxSwift

final class MockTwelveDataService: TwelveDataServiceType {
    func fetchQuote(symbol: String) -> Single<Quote> {
        let file = "quote_\(symbol.replacingOccurrences(of: "/", with: "_"))"
        if let q: Quote = MockLoader.load(file, as: Quote.self) {
            return .just(q)
        }
        let fallback = Quote(symbol: symbol, name: symbol, price: 0, changePercent: nil, previousClose: nil)
        return .just(fallback)
    }

    func fetchTimeSeries(symbol: String, interval: String = "1day", outputSize: Int = 20) -> Single<[TimeSeriesPoint]> {
        let file = "series_\(symbol.replacingOccurrences(of: "/", with: "_"))"
        if let resp: TwelveDataService.TimeSeriesResponse = MockLoader.load(file, as: TwelveDataService.TimeSeriesResponse.self) {
            return .just(resp.values)
        }
        return .just([])
    }

    func search(query: String) -> Single<[Asset]> {
        if let resp: TwelveDataService.SearchResponse = MockLoader.load("assets", as: TwelveDataService.SearchResponse.self) {
            let filtered = resp.data.filter { asset in
                let q = query.lowercased()
                return asset.symbol.lowercased().contains(q) || (asset.name.lowercased().contains(q))
            }
            return .just(filtered)
        }
        return .just([])
    }
}
