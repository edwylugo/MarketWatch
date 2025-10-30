import RxSwift
import RxCocoa

final class ActivityIndicator: SharedSequenceConvertibleType {
    typealias Element = Bool
    typealias SharingStrategy = DriverSharingStrategy

    private let relay = BehaviorRelay(value: 0)
    private let lock = NSRecursiveLock()

    func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return Observable.using({ () -> ActivityToken<O.Element> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in t.asObservable() }
    }

    func asSharedSequence() -> SharedSequence<DriverSharingStrategy, Bool> {
        return relay.asDriver().map { $0 > 0 }.distinctUntilChanged()
    }

    func asObservable() -> Observable<Bool> {
        return relay.asObservable().map { $0 > 0 }.distinctUntilChanged()
    }

    private func increment() {
        lock.lock(); defer { lock.unlock() }
        relay.accept(relay.value + 1)
    }
    private func decrement() {
        lock.lock(); defer { lock.unlock() }
        relay.accept(max(relay.value - 1, 0))
    }
}
private struct ActivityToken<E>: ObservableConvertibleType, Disposable {
    private let source: Observable<E>
    private let disposeAction: () -> Void
    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        self.source = source; self.disposeAction = disposeAction
    }
    func asObservable() -> Observable<E> { source }
    func dispose() { disposeAction() }
}
extension ObservableConvertibleType {
    func trackActivity(_ ai: ActivityIndicator) -> Observable<Element> {
        return ai.trackActivityOfObservable(self)
    }
}
