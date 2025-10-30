import UIKit

final class AssetCell: UITableViewCell {
    private let avatar = SymbolAvatarView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel().apply {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .secondaryLabel
    }
    private let priceLabel = UILabel().apply {
        $0.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
    }
    private let changeLabel = UILabel().apply {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textAlignment = .right
    }
    private let vStack = UIStackView().apply {
        $0.axis = .vertical
    }
    private let hStack = UIStackView(translateMask: false).apply {
        $0.spacing = 8
        $0.alignment = .center
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) { return nil }
}

extension AssetCell: CodeView {
    func buildViewHierarchy() {
        vStack.addArrangedSubviews([titleLabel, subtitleLabel])
        hStack.addArrangedSubviews([avatar, vStack, priceLabel, changeLabel])
        contentView.addSubview(hStack)
    }
    func setupConstraints() {
        avatar.setDimension(width: 40, height: 40)
        hStack.anchor(
            top: contentView.topAnchor, paddingTop: 12,
            leading: contentView.leadingAnchor, paddingLeft: 16,
            bottom: contentView.bottomAnchor, paddingBottom: 16,
            trailing: contentView.trailingAnchor, paddingRight: 12)
    }
}

extension AssetCell: Configurable {
    typealias Configuration = Quote
    
    func configure(content: Quote) {
        let q = content
        avatar.configure(with: q.symbol)
        titleLabel.text = q.name ?? q.symbol
        subtitleLabel.text = q.symbol
        priceLabel.text = q.price.formattedToTwoDecimals()
        priceLabel.isHidden = q.price.isZero
        if let pct = q.changePercent {
            changeLabel.text = pct.formattedAsPercent()
            changeLabel.textColor = pct >= 0 ? .systemGreen : .systemRed
        } else {
            changeLabel.text = "--"
            changeLabel.textColor = .secondaryLabel
        }
    }
}
