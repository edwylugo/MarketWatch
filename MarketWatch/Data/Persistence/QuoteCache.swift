import Foundation

final class QuoteCache {
    static let shared = QuoteCache()
    private let cache = NSCache<NSString, QuoteBox>()
    private init() { cache.countLimit = 100 }

    func set(_ q: Quote, for symbol: String) {
        cache.setObject(QuoteBox(q), forKey: symbol as NSString)
    }
    
    func get(_ symbol: String) -> Quote? {
        cache.object(forKey: symbol as NSString)?.value
    }
}

final class QuoteBox: NSObject {
    let value: Quote
    init(_ v: Quote) { self.value = v }
}

extension QuoteCache {
    func snapshot(for symbols: [String]) -> [Quote] {
        symbols.compactMap { get($0) }
    }
}
