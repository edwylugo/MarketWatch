import UIKit

final class ApplicationCoordinator {
    private let window: UIWindow
    init(window: UIWindow) { self.window = window }

    func start() {
        let service: TwelveDataServiceType = {
            if FeatureFlags.useMockAPI {
                return MockTwelveDataService()
            } else {
                let client = HTTPClient(baseURL: AppConfig.baseURL)
                return TwelveDataService(http: client, apiKey: AppConfig.apiKey)
            }
        }()
        let repo = MarketRepository(api: service)
        let fetchUseCase = FetchAssetsUseCase(repo: repo)
        let searchUseCase = SearchAssetsUseCase(repo: repo)

        let vm = AssetListViewModel(fetchAssets: fetchUseCase, searchAssets: searchUseCase)
        let list = AssetListViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: list)
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}
