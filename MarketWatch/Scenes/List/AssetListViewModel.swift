import RxSwift
import RxCocoa

// AssetListViewModel.swift
final class AssetListViewModel {
    struct Input {
        let refreshTrigger: Observable<Void>
        let searchText: Observable<String>
        let selection: Observable<IndexPath>
    }
    struct Output {
        let items: Driver<[Quote]>
        let isLoading: Driver<Bool>
        let error: Driver<String?>
        let navigateToDetail: Signal<Quote>
    }

    private let fetchAssets: FetchAssetsUseCase
    private let searchAssets: SearchAssetsUseCase
    private let scheduler: SchedulerType
    private let disposeBag = DisposeBag()

    private let defaultSymbols = ["AAPL","MSFT","GOOGL","AMZN","BTC/USD"]

    init(fetchAssets: FetchAssetsUseCase,
         searchAssets: SearchAssetsUseCase,
         scheduler: SchedulerType = MainScheduler.instance) {
        self.fetchAssets = fetchAssets
        self.searchAssets = searchAssets
        self.scheduler = scheduler
    }

    func transform(_ input: Input) -> Output {
        let activity = ActivityIndicator()
        let errorRelay = PublishRelay<String?>()
        let itemsRelay = BehaviorRelay<[Quote]>(value: [])

        let refresh = input.refreshTrigger
            .flatMapLatest { [weak self] in
                self?.fetchAssets.execute(symbols: self?.defaultSymbols ?? [])
                    .trackActivity(activity)
                    .catch { err in
                        errorRelay.accept(err.localizedDescription)
                        return .just([])
                    }
                    .asObservable()
                    .observe(on: self?.scheduler ?? MainScheduler.instance)
                ?? .just([])
            }
            .do(onNext: itemsRelay.accept)

        let search = input.searchText
            .debounce(.milliseconds(350), scheduler: scheduler)
            .distinctUntilChanged()
            .flatMapLatest { [weak self] text -> Observable<[Quote]> in
                guard let self = self else { return .just([]) }
                let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard q.isEmpty == false else { return .empty() }

                return self.searchAssets.execute(q)
                    .flatMap { assets -> Single<[Quote]> in
                        let top = assets.prefix(10).map { $0.symbol }
                        return self.fetchAssets.execute(symbols: Array(top))
                    }
                    .trackActivity(activity)
                    .catch { err in
                        errorRelay.accept(err.localizedDescription)
                        return .just([])
                    }
                    .asObservable()
                    .observe(on: self.scheduler)
            }
            .do(onNext: itemsRelay.accept)

        _ = Observable.merge(refresh, search).subscribe().disposed(by: disposeBag)

        let navigate = input.selection
            .withLatestFrom(itemsRelay.asObservable()) { idx, items -> Quote? in
                guard idx.row < items.count else { return nil }
                return items[idx.row]
            }
            .compactMap { $0 }
            .asSignal(onErrorSignalWith: .empty())

        return Output(
            items: itemsRelay.asDriver(),
            isLoading: activity.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: "Erro"),
            navigateToDetail: navigate
        )
    }
}
