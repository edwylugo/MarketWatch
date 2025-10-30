import Foundation

extension KeyedDecodingContainer {
    func decodeStringOrDouble(forKey key: Key) throws -> Double? {
        if let d = try? decode(Double.self, forKey: key) { return d }
        if let s = try? decode(String.self, forKey: key) {
            let cleaned = s.replacingOccurrences(of: ",", with: ".")
            return Double(cleaned)
        }
        return nil
    }
}
