import RxSwift

protocol TwelveDataServiceType {
    func fetchQuote(symbol: String) -> Single<Quote>
    func fetchTimeSeries(symbol: String, interval: String, outputSize: Int) -> Single<[TimeSeriesPoint]>
    func search(query: String) -> Single<[Asset]>
}

final class TwelveDataService: TwelveDataServiceType {
    private let http: HTTPClientType
    private let apiKey: String

    init(http: HTTPClientType, apiKey: String) {
        self.http = http
        self.apiKey = apiKey
    }

    func fetchQuote(symbol: String) -> Single<Quote> {
        let params = [
            "symbol": symbol,
            "apikey": apiKey
        ]
        return http.get(TwelveDataEndpoints.quote(symbol: symbol), params: params)
    }

    struct TimeSeriesResponse: Decodable { let values: [TimeSeriesPoint] }
    func fetchTimeSeries(symbol: String, interval: String, outputSize: Int) -> Single<[TimeSeriesPoint]> {
            let params = [
                "symbol": symbol,
                "interval": interval,
                "outputsize": String(outputSize),
                "apikey": apiKey
            ]
            return http.get(TwelveDataEndpoints.timeSeries, params: params)
                .map { (r: TimeSeriesResponse) in r.values }
        }

    struct SearchResponse: Decodable { let data: [Asset] }
    func search(query: String) -> Single<[Asset]> {
        let params = ["symbol": query, "apikey": apiKey]
        return http.get(TwelveDataEndpoints.symbolSearch, params: params)
            .map { (r: SearchResponse) in r.data }
    }
}

extension TwelveDataServiceType {
    func fetchTimeSeries(
        symbol: String,
        interval: String = "1day",
        outputSize: Int = 20
    ) -> Single<[TimeSeriesPoint]> {
        fetchTimeSeries(
            symbol: symbol,
            interval: interval,
            outputSize: outputSize
        )
    }
}
