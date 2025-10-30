import Quick
import Nimble
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import MarketWatch

final class AssetListViewModelTests: QuickSpec {

    override class func spec() {
        describe("AssetListViewModel") {
            var scheduler: TestScheduler!
            var disposeBag: DisposeBag!
            var mockRepo: MarketRepoMock!
            var vm: AssetListViewModel!
            var fetchUC: FetchAssetsUseCase!
            var searchUC: SearchAssetsUseCase!

            beforeEach {
                scheduler = TestScheduler(initialClock: 0)
                disposeBag = DisposeBag()
                mockRepo = MarketRepoMock()
                fetchUC = FetchAssetsUseCase(repo: mockRepo)
                searchUC = SearchAssetsUseCase(repo: mockRepo)
                vm = AssetListViewModel(
                    fetchAssets: fetchUC,
                    searchAssets: searchUC,
                    scheduler: scheduler
                )
            }

            it("emits items after refresh and toggles loading") {
                mockRepo.quoteMap = [
                    "AAPL": Quote(symbol: "AAPL", name: "Apple", price: 100, changePercent: 1.0, previousClose: 99),
                    "MSFT": Quote(symbol: "MSFT", name: "Microsoft", price: 200, changePercent: -0.5, previousClose: 201),
                    "GOOGL": Quote(symbol: "GOOGL", name: "Alphabet", price: 150, changePercent: nil, previousClose: nil),
                    "AMZN": Quote(symbol: "AMZN", name: "Amazon", price: 120, changePercent: nil, previousClose: nil),
                    "BTC/USD": Quote(symbol: "BTC/USD", name: "Bitcoin", price: 68000, changePercent: 1.2, previousClose: 67100)
                ]

                let refresh = scheduler.createColdObservable([.next(10, ())]).asObservable()
                let search = scheduler.createColdObservable([.next(200, "")]).asObservable()
                let selection = scheduler.createColdObservable([Recorded<Event<IndexPath>>]()).asObservable()

                let output = vm.transform(.init(
                    refreshTrigger: refresh,
                    searchText: search,
                    selection: selection
                ))

                let itemsObs = scheduler.createObserver([Quote].self)
                let loadingObs = scheduler.createObserver(Bool.self)
                output.items.drive(itemsObs).disposed(by: disposeBag)
                output.isLoading.drive(loadingObs).disposed(by: disposeBag)

                scheduler.start()

                let values = itemsObs.events.last?.value.element
                expect(values?.isEmpty) == false

                let loadingValues = loadingObs.events.compactMap { $0.value.element }
                expect(loadingValues).to(contain(true))
                expect(loadingValues.last) == false
            }
        }
    }
}

final class MarketRepoMock: MarketRepositoryType {
    var quoteMap: [String: Quote] = [:]
    var seriesMap: [String: [TimeSeriesPoint]] = [:]
    var searchResult: [Asset] = []
    var quoteError: Error?
    var seriesError: Error?

    func quote(for symbol: String) -> Single<Quote> {
        if let e = quoteError { return .error(e) }
        if let q = quoteMap[symbol] { return .just(q) }
        return .error(APIError.unknown(-1))
    }

    func series(for symbol: String) -> Single<[TimeSeriesPoint]> {
        if let e = seriesError { return .error(e) }
        if let s = seriesMap[symbol] { return .just(s) }
        return .just([])
    }

    func search(_ q: String) -> Single<[Asset]> {
        .just(searchResult.filter {
            let k = q.lowercased()
            return $0.symbol.lowercased().contains(k) || ($0.name.lowercased().contains(k))
        })
    }
}
