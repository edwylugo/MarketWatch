import RxSwift
import RxRelay

final class AssetDetailViewModel {
    let symbol: String
    private let repo: MarketRepositoryType
    private let disposeBag = DisposeBag()

    let quote = BehaviorRelay<Quote?>(value: nil)
    let series = BehaviorRelay<[TimeSeriesPoint]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<String?>()

    init(symbol: String, repo: MarketRepositoryType = {
        let client = HTTPClient(baseURL: AppConfig.baseURL)
        let api = TwelveDataService(http: client, apiKey: AppConfig.apiKey)
        return MarketRepository(api: api)
    }()) {
        self.symbol = symbol
        self.repo = repo
        load()
    }

    func load() {
        isLoading.accept(true)
        Single.zip(
            repo.quote(for: symbol),
            repo.series(for: symbol)
        )
        .subscribe(onSuccess: { [weak self] q, s in
            self?.quote.accept(q)
            self?.series.accept(s)
            self?.isLoading.accept(false)
        }, onFailure: { [weak self] err in
            self?.error.accept(err.localizedDescription)
            self?.isLoading.accept(false)
        })
        .disposed(by: disposeBag)
    }
}
