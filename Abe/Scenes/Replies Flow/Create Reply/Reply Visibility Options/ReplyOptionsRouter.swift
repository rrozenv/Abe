//
//  ReplyOptionsRouter.swift
//  Abe
//
//  Created by Robert Rozenvasser on 12/17/17.
//  Copyright © 2017 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import Contacts

protocol ReplyOptionsRoutingLogic {
    func toDismissNavVc()
}

final class ReplyOptionsRouter: ReplyOptionsRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toDismissNavVc() {
        navigationController?.dismiss(animated: true)
    }
    
}
