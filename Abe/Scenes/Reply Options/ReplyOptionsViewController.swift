//
//  ReplyOptionsViewController.swift
//  Abe
//
//  Created by Robert Rozenvasser on 12/17/17.
//  Copyright © 2017 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import Action

class ReplyOptionsViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: ReplyOptionsViewModel!
    
    var tableView: UITableView!
    var createReplyButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCreateButton()
        setupCancelButton()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func bindViewModel() {
        //MARK: - Input
        let input = ReplyOptionsViewModel
            .Input(createTrigger: createReplyButton.rx.tap.asDriver(),
                   visibilitySelected: tableView.rx.modelSelected(Visibility.self).asDriver(),
                   cancelTrigger: backButton.rx.tap.asDriver())
        
        //MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.visibilityOptions
            .drive(tableView.rx.items) { tableView, index, visibility in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "vis") else { fatalError() }
                cell.textLabel?.text = visibility.rawValue
                return cell
            }
            .disposed(by: disposeBag)
        
        output.didCreateReply
            .subscribe()
            .disposed(by: disposeBag)
        
        output.savedContacts
            .drive()
            .disposed(by: disposeBag)
        
        output.loading
            .drive()
            .disposed(by: disposeBag)
        
        output.errors
            .drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
}

extension ReplyOptionsViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupCancelButton() {
        backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    fileprivate func setupTableView() {
        //MARK: - tableView Properties
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "vis")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //MARK: - tableView Constraints
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    fileprivate func setupCreateButton() {
        createReplyButton = UIBarButtonItem(title: "Create", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = createReplyButton
    }
    

}
