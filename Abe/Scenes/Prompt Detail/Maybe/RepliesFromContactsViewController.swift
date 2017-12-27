
import Foundation
import RxSwift
import RxDataSources
import Action
import RxRealm
import RxRealmDataSources

//class RepliesFromContactsViewController: UIViewController {
//    
//    let disposeBag = DisposeBag()
//    var viewModel: PromptDetailViewModel!
//    var tableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTableView()
//        bindViewModel()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tableView.reloadData()
//    }
//    
//    deinit {
//        print("Prompt Detail Deinit")
//    }
//    
//    func bindViewModel() {
//        //MARK: - Input
//        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
//            .mapToVoid()
//            .asDriverOnErrorJustComplete()
//        
//        let input = PromptDetailViewModel
//            .Input(refreshTrigger: viewWillAppear,
//                   scoreSelected: PublishSubject<(CellViewModel, ScoreCellViewModel)>())
//        
//        //MARK: - Output
//        let output = viewModel.transform(input: input)
//        
//        output.replies
//            .drive(tableView.rx.items) { tableView, index, viewModel in
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: PromptReplyTableCell.reuseIdentifier) as? PromptReplyTableCell else { fatalError() }
//                
//                cell.configure(with: viewModel)
//                
//                cell.collectionView.rx
//                    .modelSelected(ScoreCellViewModel.self).asObservable()
//                    .subscribe(onNext: { scoreVm in
//                        input.scoreSelected.onNext((viewModel, scoreVm))
//                    })
//                    .disposed(by: cell.disposeBag)
//                
//                Observable.of(viewModel.scoreCellViewModels)
//                    .asDriverOnErrorJustComplete()
//                    .drive(cell.collectionView.rx.items) { collView, index, score in
//                        guard let cell = collView.dequeueReusableCell(withReuseIdentifier: ScoreCollectionCell.reuseIdentifier, for: IndexPath(row: index, section: 0)) as? ScoreCollectionCell else { fatalError() }
//                        cell.configure(with: score, userDidReply: viewModel.userDidReply)
//                        return cell
//                    }
//                    .disposed(by: cell.disposeBag)
//                
//                return cell
//            }
//            .disposed(by: disposeBag)
//        
//        output.fetching
//            .drive(onNext: { (isFetching) in
//                print("currently fetching \(isFetching)")
//            })
//            .disposed(by: disposeBag)
//        
//        output.fetchReplies
//            .drive()
//            .disposed(by: disposeBag)
//        
//        output.saveScore
//            .subscribe(onNext: { _ in
//                self.tableView.reloadData()
//            })
//            .disposed(by: disposeBag)
//        
//        output.dismissViewController
//            .drive()
//            .disposed(by: disposeBag)
//    }
//    
//}
//
//extension RepliesFromContactsViewController {
//    
//    fileprivate func setupTableView() {
//        //MARK: - tableView Properties
//        tableView = UITableView(frame: CGRect.zero, style: .grouped)
//        tableView.register(PromptReplyTableCell.self, forCellReuseIdentifier: PromptReplyTableCell.reuseIdentifier)
//        tableView.estimatedRowHeight = 200
//        tableView.rowHeight = UITableViewAutomaticDimension
//        
//        //MARK: - tableView Constraints
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { (make) in
//            make.edges.equalTo(view)
//        }
//    }
//    
//}

