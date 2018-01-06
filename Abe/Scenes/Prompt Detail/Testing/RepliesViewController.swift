//
//  RepliesViewController.swift
//  Abe
//
//  Created by Robert Rozenvasser on 1/5/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RepliesViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: RepliesViewModel!
    
    private let dataSource = RepliesDataSource()
    private var tableView: UITableView!
    private var tabBarView: TabBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear.onNext(())
    }
    
    func bindViewModel() {
        viewModel.replies.drive(onNext: { [weak self] replies in
            self?.dataSource.load(replies: replies)
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
    
    deinit {
        print("Prompt Detail Deinit")
    }
    
    fileprivate func setupTableView() {
        //MARK: - tableView Properties
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self.dataSource
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ReplyTableCell.self, forCellReuseIdentifier: ReplyTableCell.defaultReusableId)
        tableView.register(PromptSummarySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PromptSummarySectionHeaderView.reuseIdentifier)
        tableView.register(TabBarSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: TabBarSectionHeaderView.reuseIdentifier)
        
        //MARK: - tableView Constraints
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(topLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setupTabBarView() {
        tabBarView = TabBarView(leftTitle: "Trending", centerTitle: "Friends", rightTitle: "My Reply")
    }

}

extension RepliesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = RepliesDataSource.Section(rawValue: section) else { fatalError("Unexpected Section") }
        switch section {
        case .summary:
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: PromptSummarySectionHeaderView.reuseIdentifier) as? PromptSummarySectionHeaderView
            headerCell?.titleLabel.text = "Prompt Summary Cell"
            return headerCell
        default:
            return tabBarView
        }
    }
    
}
