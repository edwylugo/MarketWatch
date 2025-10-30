import Foundation

enum MockLoader {
    static func load<T: Decodable>(_ name: String, as type: T.Type) -> T? {
        guard
            let url = Bundle.main.url(forResource: "Resources/Mocks/\(name)", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(T.self, from: data)
        else { return nil }
        return decoded
    }
}
