//
//  PromptMasterDetailViewController.swift
//  Abe
//
//  Created by Robert Rozenvasser on 12/27/17.
//  Copyright © 2017 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    enum TabButtonType {
        case mainMovieList
        case contests
    }
    
    fileprivate var currentViewController: UIViewController!
    fileprivate var currentTabButton: TabButtonType {
        didSet {
            tabBarView.didSelect(tabButtonType: currentTabButton)
        }
    }
    
    fileprivate var backgroundViewForStatusBar: UIView!
    //fileprivate var customNavBar: CustomNavigationBar!
    fileprivate var tabBarView: TabBarView!
    
    fileprivate lazy var allRepliesViewController: PromptDetailViewController = { [unowned self] in
        let vc = PromptDetailViewController()
        return vc
    }()
    
    init(currentTabButton: HomeViewController.TabButtonType) {
        self.currentTabButton = currentTabButton
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        setupTabBarView()
        setCurrentViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func setCurrentViewController() {
        currentViewController = allRepliesViewController
//        switch currentTabButton {
//        case .mainMovieList:
//            currentViewController = mainMovieListViewController
//        case .contests:
//            currentViewController = contestsViewController
//        }
        self.add(asChildViewController: currentViewController)
    }
    
}


//MARK: - Tab Bar Item Selected Functions

extension HomeViewController {
    
    @objc fileprivate func didSelectLeftButton(_ sender: UIButton) {
        guard currentTabButton != .mainMovieList else { return }
        self.currentTabButton = .mainMovieList
        self.switchViewController(for: self.currentTabButton)
    }
    
    @objc fileprivate func didSelectRightButton(_ sender: UIButton) {
        guard currentTabButton != .contests else { return }
        self.currentTabButton = .contests
        self.switchViewController(for: self.currentTabButton)
    }
    
}

//MARK: - Switch View Controller Functions

extension HomeViewController {
    
    fileprivate func switchViewController(for tabBarItem: TabButtonType) {
        switchTo(allRepliesViewController)
//        switch tabBarItem {
//        case .mainMovieList:
//            switchTo(mainMovieListViewController)
//        case .contests:
//            switchTo(contestsViewController)
//        }
    }
    
    fileprivate func switchTo(_ viewController: UIViewController) {
        guard let currentViewController = self.currentViewController else { return }
        self.remove(asChildViewController: currentViewController)
        self.add(asChildViewController: viewController)
    }
    
    fileprivate func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        view.insertSubview(viewController.view, belowSubview: tabBarView)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    fileprivate func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
}

//MARK: - View Setup

extension HomeViewController {
    
//    func setupBackgroundViewForStatusBar() {
//        backgroundViewForStatusBar = UIView()
//        backgroundViewForStatusBar.backgroundColor = UIColor.white
//
//        view.addSubview(backgroundViewForStatusBar)
//        backgroundViewForStatusBar.translatesAutoresizingMaskIntoConstraints = false
//        backgroundViewForStatusBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        backgroundViewForStatusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        backgroundViewForStatusBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        backgroundViewForStatusBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
//    }

    func setupTabBarView() {
        tabBarView = TabBarView(leftTitle: "Trending", rightTitle: "Friends")
        tabBarView.didSelect(tabButtonType: currentTabButton)
        tabBarView.leftButton.addTarget(self, action: #selector(didSelectLeftButton), for: .touchUpInside)
        tabBarView.rightButton.addTarget(self, action: #selector(didSelectRightButton), for: .touchUpInside)
        
        //view.insertSubview(tabBarView, belowSubview: customNavBar)
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tabBarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        tabBarView.heightAnchor.constraint(equalToConstant: tabBarView.height).isActive = true
    }
    
}
