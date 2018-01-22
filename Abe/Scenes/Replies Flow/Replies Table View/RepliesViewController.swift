
import Foundation
import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class RepliesViewController: UIViewController, BindableType {
    
    var viewModel: RepliesViewModelType!
    private let disposeBag = DisposeBag()
    private let dataSource = RepliesDataSource()
    
    private var headerView: PromptHeaderView!
    private var tableView: UITableView!
    private var tabBarView: TabBarView!
    private var summaryView: PromptSummaryView!
    private var headerHeightConstraint:NSLayoutConstraint!
    private var createReplyButton: UIButton!
    private var backButton: UIButton!
    
    override func loadView() {
        super.loadView()
        setupTabBarView()
        setupHeaderView()
        setupTableView()
        setupSummaryView()
        setupCreatePromptReplyButton()
        setupBackButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //sizeTableHeaderToFit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppear.onNext(())
        viewModel.inputs.filterOptionSelected.onNext(.locked)
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
        
        backButton.rx.tap.asDriver()
            .drive(viewModel.inputs.backButtonTappedInput)
            .disposed(by: disposeBag)
    
        //MARK: - Outputs
        viewModel.outputs.prompt
            .drive(onNext: { [weak self] in
                self?.setPromptHeaderInfo(with: $0)
                self?.setSummaryViewInfo(with: $0)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.didUserReply
            .drive(onNext: { [weak self] didReply in
//                self?.tabBarView.isHidden = didReply ? false : true
//                guard !didReply else { return }
//                self?.dataSource.loadBeforeUserRepliedState()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.didSelectFilterOption
            .drive(onNext: { [weak self] (filterOption) in
                self?.tabBarView.selectedFilter = filterOption
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.lockedReplies.drive(onNext: { [weak self] inputs in
            self?.tabBarView.isHidden = inputs.userDidReply ? false : true
            guard inputs.userDidReply else {
                self?.dataSource.loadBeforeUserRepliedState()
                return
            }
            
            self?.dataSource.loadLocked(replies: inputs.replies,
                                        didReply: inputs.userDidReply)
            self?.tableView.reloadData()
            //self?.scrollToTop(section: .replies)
        })
        .disposed(by: disposeBag)
        
        viewModel.outputs.unlockedReplies.drive(onNext: { [weak self] replies in
            self?.dataSource.loadUnlocked(replies: replies)
            self?.tableView.reloadData()
            //self?.scrollToTop(section: .replies)
        })
        .disposed(by: disposeBag)
        
        viewModel.outputs.updateReplyWithSavedScore
            .drive(onNext: { [weak self] (inputs) in
                self?.dataSource.updateReply(inputs.0, at: inputs.1)
                self?.tableView.reloadRows(at: [inputs.1], with: .automatic)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.currentUserReplyAndScores
            .drive(onNext: { [weak self] (inputs) in
                self?.dataSource.load(myReply: inputs.0, scores: inputs.1)
                self?.tableView.reloadSections(
                    [RepliesDataSource.Section.replies.rawValue],
                    animationStyle: .automatic)
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

//MARK: - View Data Bindings
extension RepliesViewController {
    
    private func setPromptHeaderInfo(with prompt: Prompt) {
        self.headerView.titleLabel.text = prompt.title
        if let url = URL(string: prompt.imageURL) {
            self.headerView.imageView.kf.setImage(with: url)
        }
    }
    
    private func setSummaryViewInfo(with prompt: Prompt) {
        self.summaryView.bodyTextLabel.text = prompt.body
        guard let webLink = prompt.webLinkThumbnail else {
            self.summaryView.webLinkView.isHidden = true ; return
        }
        self.summaryView.webLinkView.thumbnail = webLink
    }
    
}

//MARK: - Reply Table Cell Delegate
extension RepliesViewController: ReplyTableCellDelegate {
    
    func didSelectScore(scoreViewModel: ScoreCellViewModel, at index: IndexPath) {
        viewModel.inputs.scoreSelected.onNext((scoreViewModel, index))
    }
    
}

//MARK: - Reply Table Cell Delegate
extension RepliesViewController: RateReplyTableCellDelegate {
    
    func didSelectRateReply(_ reply: PromptReply, isCurrentUsersFriend: Bool) {
        viewModel.inputs.rateReplyButtonTappedInput.onNext((reply, isCurrentUsersFriend))
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
        if let cell = cell as? RateReplyTableCell, cell.delegate == nil {
            cell.delegate = self
        }
    }
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = RepliesDataSource.Section(rawValue: section) else { fatalError("Unexpected Section") }
        switch section {
        case .summary: return summaryView
        case .replies: return tabBarView
        }
    }
    
}

extension RepliesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Going down
        if scrollView.contentOffset.y < 0 {
            self.headerView.incrementOpaqueViewAlpha(offset: self.headerHeightConstraint.constant)
            self.headerView.incrementTitleLabelAlpha(offset: self.headerHeightConstraint.constant)
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
                self.headerHeightConstraint.constant = 200
                //self.view.layoutIfNeeded()
            }, completion: nil)
        //Going up
        } else if scrollView.contentOffset.y > 0 && self.headerHeightConstraint.constant >= 65 {
            self.headerHeightConstraint.constant -= scrollView.contentOffset.y/20
            self.headerView.decrementOpaqueViewAlpha(offset: scrollView.contentOffset.y)
            self.headerView.decrementTitleLabelAlpha(offset: self.headerHeightConstraint.constant)
            if self.headerHeightConstraint.constant < 65 {
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
                    self.headerHeightConstraint.constant = 65
                    //self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.headerHeightConstraint.constant > 199 { animateHeader() }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.headerHeightConstraint.constant > 199 { animateHeader() }
    }
    
    private func animateHeader() {
        self.headerHeightConstraint.constant = 200
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    //Called in viewDidLayoutSubviews()
    private func sizeTableHeaderToFit() {
        guard let headerView = tableView.tableHeaderView else { return }
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableView.tableHeaderView = headerView
    }
    
}

//MARK: - Setup Views
extension RepliesViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        if #available(iOS 11.0, *) { tableView.contentInsetAdjustmentBehavior = .never }
        tableView.delegate = self
        tableView.dataSource = self.dataSource
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        registerTableViewCells()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(headerView.snp.bottom)
        }
    }
    
    private func setupTabBarView() {
        tabBarView = TabBarView(leftTitle: "Locked", centerTitle: "Unlocked", rightTitle: "My Reply")
        tabBarView.selectedFilter = .locked
    }
    
    private func setupSummaryView() {
        summaryView = PromptSummaryView()
        //tableView.tableHeaderView = summaryView
    }
    
    private func setupHeaderView() {
        headerView = PromptHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 200)
        headerHeightConstraint.isActive = true
        let constraints:[NSLayoutConstraint] = [
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
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
    
    private func setupBackButton() {
        let image = #imageLiteral(resourceName: "IC_BackArrow")
        image.size.equalTo(CGSize(width: 9, height: 17))
        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 9, height: 17))
        backButton.setImage(image, for: .normal)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 26, left: 20, bottom: 15, right: 15)
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.top.equalTo(view.snp.top)
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
        tableView.register(RateReplyTableCell.self, forCellReuseIdentifier: RateReplyTableCell.defaultReusableId)
        //tableView.register(ReplyTableCell.self, forCellReuseIdentifier: ReplyTableCell.defaultReusableId)
        tableView.register(PromptSummarySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PromptSummarySectionHeaderView.reuseIdentifier)
        tableView.register(TabBarSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: TabBarSectionHeaderView.reuseIdentifier)
        tableView.register(SavedReplyScoreTableCell.self, forCellReuseIdentifier: SavedReplyScoreTableCell.defaultReusableId)
        tableView.register(RepliesEmptyCell.self, forCellReuseIdentifier: RepliesEmptyCell.defaultReusableId)
    }
    
}
