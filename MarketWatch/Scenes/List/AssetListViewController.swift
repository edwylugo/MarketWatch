import UIKit
import RxSwift
import RxCocoa

final class AssetListViewController: UIViewController {
    private let tableView = UITableView(translateMask: false)
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)

    private let viewModel: AssetListViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: AssetListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { return nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBinds()
    }

    private func setupBinds() {
        let input = AssetListViewModel.Input(
            refreshTrigger: Observable.merge(
                Observable.just(()),
                refreshControl.rx.controlEvent(.valueChanged).asObservable()
            ),
            searchText: searchController.searchBar.rx.text.orEmpty.asObservable(),
            selection: tableView.rx.itemSelected.asObservable()
        )

        let output = viewModel.transform(input)

        output.items
            .drive(tableView.rx.items(cellIdentifier: "AssetCell", cellType: AssetCell.self)) { _, item, cell in
                cell.configure(content: item)
            }
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] loading in
                if loading { self?.refreshControl.beginRefreshing() }
                else { self?.refreshControl.endRefreshing() }
            })
            .disposed(by: disposeBag)

        output.navigateToDetail
            .emit(onNext: { [weak self] quote in
                let detailVM = AssetDetailViewModel(symbol: quote.symbol)
                let vc = AssetDetailViewController(viewModel: detailVM)
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        output.error
            .drive(onNext: { [weak self] message in
                guard let message = message else { return }
                AlertUtils.showError(on: self, message: message)
            })
            .disposed(by: disposeBag)
    }
}

extension AssetListViewController: CodeView {
    func buildViewHierarchy() {
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        tableView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor
        )
    }
    
    func setupAdditionalConfiguration() {
        title = "MarketWatch"
        view.backgroundColor = .systemBackground
        tableView.register(AssetCell.self, forCellReuseIdentifier: "AssetCell")
        tableView.refreshControl = refreshControl
        navigationItem.searchController = searchController
    }
}
