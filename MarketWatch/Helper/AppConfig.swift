import Foundation

enum AppConfig {
    static func string(for key: String) -> String? {
        guard
            let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let value = dict[key] as? String
        else { return nil }
        return value
    }

    static var apiKey: String { AppConfig.string(for: "TWELVE_DATA_API_KEY") ?? "" }
    static var baseURL: String { AppConfig.string(for: "TWELVE_DATA_BASE_URL") ?? "https://api.twelvedata.com" }
}
