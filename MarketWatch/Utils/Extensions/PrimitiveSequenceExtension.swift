import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {
    func retryRateLimitedWith(_ retryAfter: @escaping (Error) -> TimeInterval?) -> Single<Element> {
        self.retry { errors in
            errors.flatMap { error -> Observable<Int> in
                guard case APIError.rateLimited(let header) = error else { return .error(error) }
                let delay = retryAfter(error) ?? (header ?? 1.5)
                return Observable<Int>.timer(.milliseconds(Int(delay * 1000)), scheduler: MainScheduler.instance).take(1)
            }
        }
    }
}
