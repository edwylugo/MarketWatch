import RxSwift

struct FetchQuoteUseCase {
    let repo: MarketRepositoryType
    func execute(symbol: String) -> Single<Quote> {
        repo.quote(for: symbol)
    }
}
