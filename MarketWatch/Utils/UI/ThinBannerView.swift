import UIKit

final class ThinBannerView: UIView {
    private let label = UILabel()
    private var hideTask: DispatchWorkItem?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.systemYellow.withAlphaComponent(0.95)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        alpha = 0
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) { return nil }

    func show(message: String, in view: UIView, duration: TimeInterval = 2.5) {
        label.text = message
        view.addSubview(self)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
        UIView.animate(withDuration: 0.25) { self.alpha = 1 }

        hideTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            UIView.animate(withDuration: 0.25, animations: { self?.alpha = 0 }) { _ in
                self?.removeFromSuperview()
            }
        }
        hideTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
    }
}
