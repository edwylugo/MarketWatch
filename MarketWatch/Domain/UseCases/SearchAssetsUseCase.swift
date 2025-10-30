import RxSwift

struct SearchAssetsUseCase {
    let repo: MarketRepositoryType
    func execute(_ q: String) -> Single<[Asset]> {
        repo.search(q)
    }
}
