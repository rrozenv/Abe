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
    func toPromptDetail()
}

final class ReplyOptionsRouter: ReplyOptionsRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toPromptDetail() {
        navigationController?.dismiss(animated: true)
    }
    
}
