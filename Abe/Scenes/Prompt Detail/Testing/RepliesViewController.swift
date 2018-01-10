
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
        let lockedTapped = tabBarView.leftButton.rx.tap
            .map { _ in FilterOption.locked }
            .asDriverOnErrorJustComplete()
        
        let unlockedTapped = tabBarView.centerButton.rx.tap
            .map { _ in FilterOption.unlocked }
            .asDriverOnErrorJustComplete()
        
        let myReplyTapped = tabBarView.rightButton.rx.tap
            .map { _ in FilterOption.myReply }
            .asDriverOnErrorJustComplete()
        
        let filterOptionTapped = Observable
            .of(lockedTapped, unlockedTapped, myReplyTapped)
            .merge()
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .locked)
        
        createReplyButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.createReplyTapped)
            .disposed(by: disposeBag)
        
        filterOptionTapped
            .drive(viewModel.inputs.filterOptionSelected)
            .disposed(by: disposeBag)
    
        //MARK: - Outputs
        viewModel.outputs.didUserReply
            .drive()
            //.drive(createReplyButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.didSelectFilterOption
            .drive(onNext: { [weak self] (filterOption) in
                self?.tabBarView.selectedFilter = filterOption
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.lockedReplies.drive(onNext: { [weak self] replies in
            self?.dataSource.load(replies: replies)
            self?.tableView.reloadData()
            let indexPath = IndexPath(row: 0, section: RepliesDataSource.Section.replies.rawValue)
            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        })
        .disposed(by: disposeBag)
        
        viewModel.outputs.unlockedReplies.drive(onNext: { [weak self] replies in
            self?.dataSource.load(replies: replies)
            self?.tableView.reloadData()
            let indexPath = IndexPath(row: 0, section: RepliesDataSource.Section.replies.rawValue)
            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        })
        .disposed(by: disposeBag)
        
        viewModel.outputs.updateReplyWithSavedScore
            .drive(onNext: { [weak self] (inputs) in
                self?.dataSource.updateReply(inputs.0, at: inputs.1)
                self?.tableView.reloadRows(at: [inputs.1], with: .none)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.currentUserReplyAndScores
            .drive(onNext: { [weak self] (inputs) in
                self?.dataSource.load(myReply: inputs.0, scores: inputs.1)
                self?.tableView.reloadSections(
                    [RepliesDataSource.Section.replies.rawValue],
                    animationStyle: .none)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.routeToCreateReply
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel.outputs.stillUnreadFromFriendsCount
            .drive(onNext: {
                print($0)
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
        tableView.register(SavedReplyScoreTableCell.self, forCellReuseIdentifier: SavedReplyScoreTableCell.defaultReusableId)
        
        //MARK: - tableView Constraints
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(topLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setupTabBarView() {
        tabBarView = TabBarView(leftTitle: "Locked", centerTitle: "Unlocked", rightTitle: "My Reply")
        tabBarView.selectedFilter = .locked
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
    
    func didSelectScore(scoreViewModel: ScoreCellViewModel, at index: IndexPath) {
        print("score selectd at index \(index)")
        viewModel.inputs.scoreSelected.onNext((scoreViewModel, index))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = RepliesDataSource.Section(rawValue: section) else { fatalError("Unexpected Section") }
        switch section {
        case .summary:
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: PromptSummarySectionHeaderView.reuseIdentifier) as? PromptSummarySectionHeaderView
            headerCell?.titleLabel.text = "Prompt Summary Cell"
            return headerCell
        case .replies:
            return tabBarView
        }
    }
    
}
