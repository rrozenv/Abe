
import Foundation
import UIKit

protocol CreateUserRoutingLogic {
    func toHome()
}

class CreateUserRouter: CreateUserRoutingLogic {
    
    func toHome() {
        NotificationCenter.default.post(name: .closeLoginVC, object: nil)
    }
    
}
