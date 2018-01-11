//
//  PromptSummarySectionHeaderView.swift
//  Abe
//
//  Created by Robert Rozenvasser on 1/5/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class  PromptSummarySectionHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "PromptSummarySectionHeaderView"
    var containerView: UIView!
    var titleLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.clear
        setupContainerView()
        setupTitleLabel()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.red
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.snp.makeConstraints { (make) in
            make.edges.edges.equalTo(self)
            make.height.equalTo(200)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(containerView.snp.center)
        }
    }
    
}

final class  TabBarSectionHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "TabBarSectionHeaderView"
    var tabBarView: TabBarView!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.clear
        setupTabBarView()
    }
    
    private func setupTabBarView() {
        tabBarView = TabBarView(leftTitle: "Trending",
                                centerTitle: "Friends",
                                rightTitle: "My Reply")
        
        self.addSubview(tabBarView)
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.snp.makeConstraints { (make) in
            make.edges.edges.equalTo(self)
            make.height.equalTo(50)
        }
    }
    
}
