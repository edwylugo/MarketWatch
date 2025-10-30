import RxSwift

struct FetchAssetsUseCase {
    let repo: MarketRepositoryType
    func execute(symbols: [String]) -> Single<[Quote]> {
        sequentialQuotes(symbols: symbols, repo: repo)
    }
}

func sequentialQuotes(symbols: [String], repo: MarketRepositoryType) -> Single<[Quote]> {
    Observable.from(symbols)
        .concatMap { symbol in repo.quote(for: symbol).asObservable() }
        .toArray()
}
