import RxSwift
protocol MarketRepositoryType {
    func quote(for symbol: String) -> Single<Quote>
    func series(for symbol: String) -> Single<[TimeSeriesPoint]>
    func search(_ q: String) -> Single<[Asset]>
}

final class MarketRepository: MarketRepositoryType {
    private let api: TwelveDataServiceType
    init(api: TwelveDataServiceType) { self.api = api }

    func quote(for symbol: String) -> Single<Quote> { api.fetchQuote(symbol: symbol) }
    func series(for symbol: String) -> Single<[TimeSeriesPoint]> { api.fetchTimeSeries(symbol: symbol) }
    func search(_ q: String) -> Single<[Asset]> { api.search(query: q) }
}
