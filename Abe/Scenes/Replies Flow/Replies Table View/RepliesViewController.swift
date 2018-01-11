
import Foundation
import UIKit
import RxSwift
import RxCocoa

class RepliesViewController: UIViewController {
    
    var viewModel: RepliesViewModelType!
    private let disposeBag = DisposeBag()
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
        
        createReplyButton.rx.tap.asDriver()
            .drive(viewModel.inputs.createReplyTapped)
            .disposed(by: disposeBag)
        
        filterOptionTapped
            .drive(viewModel.inputs.filterOptionSelected)
            .disposed(by: disposeBag)
    
        //MARK: - Outputs
        viewModel.outputs.didUserReply
            .drive(onNext: { [weak self] didReply in
                self?.tabBarView.isHidden = didReply ? false : true
                guard !didReply else { return }
                self?.dataSource.loadBeforeUserRepliedState()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.didSelectFilterOption
            .drive(onNext: { [weak self] (filterOption) in
                self?.tabBarView.selectedFilter = filterOption
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.lockedReplies.drive(onNext: { [weak self] inputs in
            self?.dataSource.loadLocked(replies: inputs.replies,
                                        didReply: inputs.userDidReply)
            self?.tableView.reloadData()
            self?.scrollToTop(section: .replies)
        })
        .disposed(by: disposeBag)
        
        viewModel.outputs.unlockedReplies.drive(onNext: { [weak self] replies in
            self?.dataSource.loadUnlocked(replies: replies)
            self?.tableView.reloadData()
            self?.scrollToTop(section: .replies)
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
    
    deinit { print("Prompt Detail Deinit") }
    
}

//MARK: - Reply Table Cell Delegate
extension RepliesViewController: ReplyTableCellDelegate {
    
    func didSelectScore(scoreViewModel: ScoreCellViewModel, at index: IndexPath) {
        viewModel.inputs.scoreSelected.onNext((scoreViewModel, index))
    }
    
}

//MARK: - Table View Delegate
extension RepliesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if let cell = cell as? ReplyTableCell, cell.delegate == nil {
            cell.delegate = self
        }
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

//MARK: - Setup Views
extension RepliesViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self.dataSource
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        registerTableViewCells()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(topLayoutGuide.snp.bottom)
        }
    }
    
    private func setupTabBarView() {
        tabBarView = TabBarView(leftTitle: "Locked", centerTitle: "Unlocked", rightTitle: "My Reply")
        tabBarView.selectedFilter = .locked
    }
    
    private func setupCreatePromptReplyButton() {
        createReplyButton = UIButton()
        createReplyButton.backgroundColor = UIColor.black
        createReplyButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        createReplyButton.setTitle("Reply", for: .normal)
        
        view.addSubview(createReplyButton)
        createReplyButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(60)
        }
    }
    
}

//MARK: - Helper Methods
extension RepliesViewController {
    
    private func scrollToTop(section: RepliesDataSource.Section) {
        let indexPath = IndexPath(row: 0, section: section.rawValue)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    private func registerTableViewCells() {
        tableView.register(ReplyTableCell.self, forCellReuseIdentifier: ReplyTableCell.defaultReusableId)
        tableView.register(PromptSummarySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PromptSummarySectionHeaderView.reuseIdentifier)
        tableView.register(TabBarSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: TabBarSectionHeaderView.reuseIdentifier)
        tableView.register(SavedReplyScoreTableCell.self, forCellReuseIdentifier: SavedReplyScoreTableCell.defaultReusableId)
        tableView.register(RepliesEmptyCell.self, forCellReuseIdentifier: RepliesEmptyCell.defaultReusableId)
    }
    
}
