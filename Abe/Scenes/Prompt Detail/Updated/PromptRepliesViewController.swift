
import Foundation
import RxSwift
import RxDataSources
import Action
import RxRealm
import RxRealmDataSources

//class PromptRepliesViewController: UIViewController {
//    
//    let disposeBag = DisposeBag()
//    
//    var viewModel: PromptRepliesViewModel!
//    var tableView: UITableView!
//    var createReplyButton: UIButton!
//    var backButton: UIBarButtonItem!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTableView()
//        setupCreatePromptReplyButton()
//        setupCancelButton()
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
//       let input = PromptRepliesViewModel.Input(scoreSelected: PublishSubject<CellViewModel>())
//        
//       let output = viewModel.transform(input: input)
//        
//        output.replies
//            .drive(onNext: { [unowned self] (_) in
//                self.tableView.reloadData()
//            })
//            .disposed(by: disposeBag)
//    }
//    
//}
//
//extension PromptRepliesViewController: UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.numberOfReplies
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: PromptReplyTableCell.reuseIdentifier, for: indexPath) as? PromptReplyTableCell else { fatalError("Unexpected Table View Cell") }
//        
//        if let viewModel = viewModel.viewModelForReply(at: indexPath.row) {
//            cell.configure(with: viewModel)
//            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
//        }
//        
//        return cell
//    }
//    
//}
//
//extension PromptRepliesViewController: UICollectionViewDataSource {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 5
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScoreCollectionCell.reuseIdentifier, for: indexPath) as? ScoreCollectionCell else { fatalError() }
//        if let viewModel = viewModel.viewModelForScore(at: indexPath.row) {
//            cell.configure(with: viewModel)
//        }
//        return cell
//    }
//    
//}
//
//extension PromptRepliesViewController: UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let viewModel = viewModel.viewModelForScore(at: indexPath.row) {
//            print(viewModel.value)
//        }
//    }
//    
//}
//
//extension PromptRepliesViewController {
//    
//    fileprivate func setupCancelButton() {
//        backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
//        self.navigationItem.leftBarButtonItem = backButton
//    }
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
//    fileprivate func setupCreatePromptReplyButton() {
//        //MARK: - createPromptButton Properties
//        createReplyButton = UIButton()
//        createReplyButton.backgroundColor = UIColor.black
//        createReplyButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
//        createReplyButton.setTitle("Reply", for: .normal)
//        
//        //MARK: - createPromptButton Constraints
//        view.addSubview(createReplyButton)
//        createReplyButton.snp.makeConstraints { (make) in
//            make.left.bottom.right.equalTo(view)
//            make.height.equalTo(60)
//        }
//    }
//    
//    
//}

