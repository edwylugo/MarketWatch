import UIKit

extension UIViewController {
    func showBanner(_ message: String) {
        let banner = ThinBannerView()
        banner.show(message: message, in: self.view)
    }
}
