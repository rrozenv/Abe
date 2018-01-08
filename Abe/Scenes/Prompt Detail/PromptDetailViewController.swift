
import Foundation
import RxSwift
import RxDataSources
import Action
import RxRealm
import RxRealmDataSources

class PromptDetailViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: PromptDetailViewModel!
    var scoreSelected = PublishSubject<(CellViewModel, ScoreCellViewModel)>()
    
    var tabBarView: TabBarView!
    var tableView: UITableView!
    var createReplyButton: UIButton!
    var backButton: UIBarButtonItem!
    var emptyView: RepliesEmptyView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarView()
        setupTableView()
        setupEmptyView()
        setupCreatePromptReplyButton()
        setupCancelButton()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    deinit {
        print("Prompt Detail Deinit")
    }
    
    func bindViewModel() {
        
        //MARK: - Input
        let viewDidLoad = rx.sentMessage(#selector(UIViewController.viewDidLoad))
            .mapToVoid()
        
        let userUpdatedNotification = NotificationCenter.default.rx
            .notification(Notification.Name.userUpdated)
            .mapToVoid()
        
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
            .startWith(.all)
            .asDriver(onErrorJustReturn: .all)
        
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
      
        let input = PromptDetailViewModel
            .Input(viewDidLoad: viewDidLoad,
                   userUpdatedNotification: userUpdatedNotification,
                   viewWillAppear: viewWillAppear,
                   visibilitySelected: visibilitySelected,
                   createReplyTrigger: createReplyButton.rx.tap.asDriver(),
                   backTrigger: backButton.rx.tap.asDriver(),
                   scoreSelected: scoreSelected)
        
        //MARK: - Output
        let output = viewModel.transform(input: input)
        
//        output.replies
//            .drive(tableView.rx.items) { tableView, index, replyCellviewModel in
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: PromptReplyTableCell.reuseIdentifier) as? PromptReplyTableCell else { fatalError() }
//
//                cell.configure(with: replyCellviewModel)
//
//                cell.collectionView.rx
//                    .modelSelected(ScoreCellViewModel.self).asObservable()
//                    .subscribe(onNext: { scoreVm in
//                        input.scoreSelected.onNext((replyCellviewModel, scoreVm))
//                    })
//                    .disposed(by: cell.disposeBag)
//
//                Observable.of(replyCellviewModel.scoreCellViewModels)
//                    .asDriverOnErrorJustComplete()
//                    .drive(cell.collectionView.rx.items) { collView, index, score in
//                        guard let cell = collView.dequeueReusableCell(withReuseIdentifier: ScoreCollectionCell.reuseIdentifier, for: IndexPath(row: index, section: 0)) as? ScoreCollectionCell else { fatalError() }
//                        cell.configure(with: score,
//                                       userDidReply: replyCellviewModel.userDidReply)
//                        return cell
//                    }
//                    .disposed(by: cell.disposeBag)
//
//                return cell
//            }
//            .disposed(by: disposeBag)
        
        output.replies
            .drive(onNext: { _ in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.replies
            .map { $0.isEmpty }
            .drive(onNext: { self.emptyView.isHidden = $0 ? false : true })
            .disposed(by: disposeBag)
        
        output.shouldDisplayReplies
            .drive(onNext: {
                //self.emptyView.isHidden = $0 //? false : true
                self.createReplyButton.isHidden = $0
            })
            .disposed(by: disposeBag)
        
        output.fetching
            .drive(onNext: { (isFetching) in
                print("currently fetching \(isFetching)")
            })
            .disposed(by: disposeBag)
        
        output.createReply
            .drive()
            .disposed(by: disposeBag)
        
        //Automatically reloads row
        output.saveScore
            .subscribe()
            .disposed(by: disposeBag)
        
        output.dismissViewController
            .drive()
            .disposed(by: disposeBag)
        
        output.didBindReplies
            .disposed(by: disposeBag)
        
        output.currentVisibility
            .drive(onNext: { [unowned self] vis in
                self.tabBarView.selectedVisibility = vis
                self.emptyView.selectedVisibility = vis
            })
            .disposed(by: disposeBag)
        
        output.didUpdateUser
            .subscribe()
            .disposed(by: disposeBag)
        
        //        output.saveScore
        //            .subscribe(onNext: { replyCellViewModel in
        //                let indexPath = IndexPath(row: replyCellViewModel.index, section: 0)
        //                self.tableView.reloadRows(at: [indexPath], with: .none)
        //            })
        //            .disposed(by: disposeBag)
    }

}

extension PromptDetailViewController: UITableViewDataSource {
    
    fileprivate enum Section: Int {
        case promptSummary = 0
        case replies = 1

        static var count: Int { return Section.replies.rawValue + 1 }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { fatalError("Unexpected Section") }
        switch section {
        case .promptSummary: return 0
        case .replies: return viewModel.numberOfReplies
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Unexpected Section") }
        switch section {
        case .promptSummary:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell") else { fatalError() }
            return cell
        case .replies:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PromptReplyTableCell.reuseIdentifier) as? PromptReplyTableCell else { fatalError() }
            
            let replyViewModel = viewModel.replies[indexPath.row]
            cell.configure(with: replyViewModel)
            
            cell.collectionView.rx
                .modelSelected(ScoreCellViewModel.self).asObservable()
                .subscribe(onNext: { scoreVm in
                    self.scoreSelected.onNext((replyViewModel, scoreVm))
                })
                .disposed(by: cell.disposeBag)
            
            Observable.of(replyViewModel.scoreCellViewModels)
                .asDriverOnErrorJustComplete()
                .drive(cell.collectionView.rx.items) { collView, index, score in
                    guard let cell = collView.dequeueReusableCell(withReuseIdentifier: ScoreCollectionCell.reuseIdentifier, for: IndexPath(row: index, section: 0)) as? ScoreCollectionCell else { fatalError() }
                    cell.configure(with: score)
                    return cell
                }
                .disposed(by: cell.disposeBag)
            
            return cell
        }
    }
    
}

extension PromptDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section) else { fatalError("Unexpected Section") }
        switch section {
        case .promptSummary:
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: PromptSummarySectionHeaderView.reuseIdentifier) as? PromptSummarySectionHeaderView
            headerCell?.titleLabel.text = "Prompt Summary Cell"
            return headerCell
        default:
//            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TabBarSectionHeaderView.reuseIdentifier) as? TabBarSectionHeaderView
            return tabBarView
        }
    }
    
}

extension PromptDetailViewController {
    
    fileprivate func setupEmptyView() {
        emptyView = RepliesEmptyView()
        
        view.insertSubview(emptyView, belowSubview: tabBarView)
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    fileprivate func setupCancelButton() {
        backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    fileprivate func setupTableView() {
        //MARK: - tableView Properties
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PromptReplyTableCell.self, forCellReuseIdentifier: PromptReplyTableCell.reuseIdentifier)
        tableView.register(PromptSummarySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PromptSummarySectionHeaderView.reuseIdentifier)
        tableView.register(TabBarSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: TabBarSectionHeaderView.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmptyCell")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //MARK: - tableView Constraints
        view.insertSubview(tableView, belowSubview: tabBarView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(topLayoutGuide.snp.bottom)
        }
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
    
    func setupTabBarView() {
        tabBarView = TabBarView(leftTitle: "Trending", centerTitle: "Friends", rightTitle: "My Reply")
        //tabBarView.isHidden = true
        
//        view.addSubview(tabBarView)
        //tabBarView.translatesAutoresizingMaskIntoConstraints = false
//        tabBarView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
//        tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        tabBarView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        //tabBarView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
}


