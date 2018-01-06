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
    private var createReplyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCreatePromptReplyButton()
        setupTabBarView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear.onNext(())
    }
    
    func bindViewModel() {
        let allTapped = tabBarView.leftButton.rx.tap
            .map { _ in Visibility.all }
            .asDriverOnErrorJustComplete()
        
        let contactsTapped = tabBarView.centerButton.rx.tap
            .map { _ in Visibility.contacts }
            .asDriverOnErrorJustComplete()
        
        let myReplyTapped = tabBarView.rightButton.rx.tap
            .map { _ in Visibility.userReply }
            .asDriverOnErrorJustComplete()
        
        let visibilitySelected = Observable
            .of(allTapped, contactsTapped, myReplyTapped)
            .merge()
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .all)
        
        visibilitySelected
            .drive(viewModel.visibilitySelected)
            .disposed(by: disposeBag)
        
        viewModel.didUserReply
            .drive(createReplyButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.currentVisibility
            .drive(onNext: { [weak self] (vis) in
                self?.tabBarView.selectedVisibility = vis
            })
            .disposed(by: disposeBag)
        
        viewModel.allReplies.drive(onNext: { [weak self] replies in
            self?.dataSource.load(replies: replies)
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
        
        viewModel.contactReplies.drive(onNext: { [weak self] replies in
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
    
    fileprivate func setupCreatePromptReplyButton() {
        //MARK: - createPromptButton Properties
        createReplyButton = UIButton()
        createReplyButton.backgroundColor = UIColor.black
        createReplyButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        createReplyButton.setTitle("Reply", for: .normal)
        
        //MARK: - createPromptButton Constraints
        view.addSubview(createReplyButton)
        createReplyButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(60)
        }
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
