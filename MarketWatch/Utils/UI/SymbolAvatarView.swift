import UIKit

final class SymbolAvatarView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.secondarySystemFill
        layer.cornerRadius = 20
        layer.masksToBounds = true

        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 40),
            heightAnchor.constraint(equalToConstant: 40),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { return nil }

    func configure(with symbol: String) {
        // pega até 4 caracteres visíveis
        let text = String(symbol.prefix(4)).uppercased()
        label.text = text
        // opcional: mude a cor de fundo a partir de um hash do símbolo
        backgroundColor = color(for: symbol)
    }

    private func color(for symbol: String) -> UIColor {
        let hash = abs(symbol.hashValue)
        let hue = CGFloat((hash % 256)) / 255.0
        return UIColor(hue: hue, saturation: 0.2, brightness: 0.9, alpha: 1.0)
    }
}
