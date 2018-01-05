
import Foundation
import RxSwift
import RxDataSources
import Action
import RxRealm
import RxRealmDataSources

class PromptDetailViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: PromptDetailViewModel!
    
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
                   scoreSelected: PublishSubject<(CellViewModel, ScoreCellViewModel)>())
        
        //MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.replies
            .drive(tableView.rx.items) { tableView, index, replyCellviewModel in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PromptReplyTableCell.reuseIdentifier) as? PromptReplyTableCell else { fatalError() }
               
                cell.configure(with: replyCellviewModel)
                
                cell.collectionView.rx
                    .modelSelected(ScoreCellViewModel.self).asObservable()
                    .subscribe(onNext: { scoreVm in
                        input.scoreSelected.onNext((replyCellviewModel, scoreVm))
                    })
                    .disposed(by: cell.disposeBag)
                
                Observable.of(replyCellviewModel.scoreCellViewModels)
                    .asDriverOnErrorJustComplete()
                    .drive(cell.collectionView.rx.items) { collView, index, score in
                        guard let cell = collView.dequeueReusableCell(withReuseIdentifier: ScoreCollectionCell.reuseIdentifier, for: IndexPath(row: index, section: 0)) as? ScoreCollectionCell else { fatalError() }
                        cell.configure(with: score,
                                       userDidReply: replyCellviewModel.userDidReply)
                        return cell
                    }
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
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
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(PromptReplyTableCell.self, forCellReuseIdentifier: PromptReplyTableCell.reuseIdentifier)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //MARK: - tableView Constraints
        view.insertSubview(tableView, belowSubview: tabBarView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
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
        
        view.addSubview(tabBarView)
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tabBarView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        tabBarView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
}


