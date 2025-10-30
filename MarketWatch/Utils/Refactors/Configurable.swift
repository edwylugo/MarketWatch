import Foundation
import UIKit

protocol Configurable: AnyObject {
    associatedtype Configuration
    func configure(content: Configuration)
}
