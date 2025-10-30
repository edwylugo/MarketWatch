import UIKit
import RxSwift
import RxCocoa

final class AssetDetailViewController: UIViewController {
    private let vm: AssetDetailViewModel
    private let priceLabel = UILabel().apply {
        $0.font = .monospacedDigitSystemFont(ofSize: 24, weight: .bold)
    }
    private let changeLabel = UILabel().apply {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }
    private let prevCloseLabel = UILabel()
    private let graphView = UIView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let stackView = UIStackView(translateMask: false).apply {
        $0.axis = .vertical
        $0.spacing = 12
    }
    private let disposeBag = DisposeBag()

    init(viewModel: AssetDetailViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { return nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupBind()
    }

    private func setupBind() {
        vm.quote.asDriver()
            .drive(onNext: { [weak self] q in
                guard let q = q else { return }
                self?.title = q.name ?? q.symbol
                self?.priceLabel.text = q.price.formattedToTwoDecimals()
                self?.priceLabel.isHidden = q.price.isZero
                if let pct = q.changePercent {
                    self?.changeLabel.text = pct.formattedAsPercent()
                    self?.changeLabel.textColor = pct >= 0 ? .systemGreen : .systemRed
                } else {
                    self?.changeLabel.text = "--"
                    self?.changeLabel.textColor = .secondaryLabel
                }
                if let prev = q.previousClose {
                    self?.prevCloseLabel.text = "Último fechamento: " + prev.formattedToTwoDecimals()
                } else {
                    self?.prevCloseLabel.text = "Último fechamento: --"
                }
            })
            .disposed(by: disposeBag)

        vm.series.asDriver()
            .drive(onNext: { [weak self] points in
                self?.drawLineChart(points: points)
            })
            .disposed(by: disposeBag)

        vm.isLoading.asDriver()
            .drive(onNext: { [weak self] loading in
                if loading { self?.spinner.startAnimating() } else { self?.spinner.stopAnimating() }
            })
            .disposed(by: disposeBag)

        vm.error.asSignal()
            .emit(onNext: { [weak self] message in
                guard let message = message else { return }
                AlertUtils.showError(on: self, message: message)
            })
            .disposed(by: disposeBag)
    }

    private func drawLineChart(points: [TimeSeriesPoint]) {
        graphView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        guard points.isEmpty == false else { return }
        let doubles = points.compactMap { Double($0.close) }
        guard doubles.isEmpty == false else { return }

        let width = graphView.bounds.width
        let height = graphView.bounds.height
        let maxV = doubles.max() ?? 0
        let minV = doubles.min() ?? 0
        let span = max(maxV - minV, 0.0001)

        let path = UIBezierPath()
        for (i, v) in doubles.enumerated() {
            let x = width * CGFloat(i) / CGFloat(max(doubles.count - 1, 1))
            let y = height - (height * CGFloat((v - minV) / span))
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.label.withAlphaComponent(0.8).cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 2
        graphView.layer.addSublayer(shape)
    }
}

extension AssetDetailViewController: CodeView {
    func buildViewHierarchy() {
        view.addSubview(stackView)
        stackView.addArrangedSubviews([
            priceLabel,
            changeLabel,
            prevCloseLabel,
            graphView,
            spinner
        ])
    }
    
    func setupConstraints() {
        stackView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 16,
            leading: view.leadingAnchor,
            paddingLeft: 16,
            trailing: view.trailingAnchor,
            paddingRight: 16
        )
        
        graphView.setHeight(height: 160)
    }
    
    func setupAdditionalConfiguration() {
        spinner.hidesWhenStopped = true
    }
}
