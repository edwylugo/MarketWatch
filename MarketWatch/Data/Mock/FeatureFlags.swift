import Foundation

enum FeatureFlags {
    static var useMockAPI: Bool {
        let args = ProcessInfo.processInfo.arguments
        return args.contains("-USE_MOCK_API=1")
    }
}
