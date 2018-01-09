
import Foundation
import UIKit
import RxSwift
import RxCocoa

class RepliesViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: RepliesViewModelType!
    
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
        viewModel.inputs.viewWillAppear.onNext(())
    }
    
    func bindViewModel() {
        
        //MARK: - Inputs
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
        
        createReplyButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.createReplyTapped)
            .disposed(by: disposeBag)
        
        visibilitySelected
            .drive(viewModel.inputs.visibilitySelected)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.didUserReply
            .drive(createReplyButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.currentVisibility
            .drive(onNext: { [weak self] (vis) in
                self?.tabBarView.selectedVisibility = vis
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.allReplies.drive(onNext: { [weak self] replies in
            self?.dataSource.realmLoad(replies: replies)
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
        
        viewModel.outputs.contactReplies.drive(onNext: { [weak self] replies in
            self?.dataSource.load(replies: replies)
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
        
        viewModel.outputs.routeToCreateReply
            .subscribe()
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

extension RepliesViewController: UITableViewDelegate, ReplyTableCellDelegate {
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if let cell = cell as? ReplyTableCell, cell.delegate == nil {
            cell.delegate = self
        }
    }
    
    func didSelectScore() {
        print("Score selected!")
    }
    
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
