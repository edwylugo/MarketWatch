import UIKit

final class AlertUtils {
    static func showError(on viewController: UIViewController?, message: String, title: String = "Erro", confirmTitle: String = "Ok") {
        guard let viewController = viewController else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default))
        viewController.present(alert, animated: true)
    }
}
