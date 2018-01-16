//
//  AddWebLinkRouter.swift
//  Abe
//
//  Created by Robert Rozenvasser on 1/16/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

protocol AddWebLinkRoutingLogic {
    func toMainCreateReplyInput()
}

final class AddWebLinkRouter: AddWebLinkRoutingLogic {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toMainCreateReplyInput() {
        navigationController.popViewController(animated: true)
    }
    
}
