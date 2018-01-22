
import Foundation
import Foundation
import RxSwift

class GuessReplyAuthorViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    let dataSource = GuessReplyAuthorDataSource()
    var viewModel: GuessReplyAuthorViewModel!
    private var nextButton: UIButton!
    
    var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        setupTableView()
        setupNextButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppearInput.onNext(())
    }
    
    deinit { print("wager deinit") }
    
    func bindViewModel() {
        
//MARK: - Input
        tableView.rx.itemSelected.asObservable()
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedIndexPathInput)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .map { [weak self] in self?.dataSource.user(at: $0) }.unwrap()
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedUserViewModelInput)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(to: viewModel.inputs.nextButtonTappedInput)
            .disposed(by: disposeBag)
        
//MARK: - Output
        viewModel.outputs.currentUsersFriends
            .drive(onNext: { [weak self] in
                self?.dataSource.loadUsers(ratings: $0)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.previousAndCurrentIndexPath
            .subscribe(onNext: { [weak self] (indexPaths) in
                self?.dataSource.toggleUser(at: indexPaths.current)
                self?.tableView.reloadRows(at: [indexPaths.current], with: .none)
                
                //First value will contain a previous.row = -1
                //because there is no previous indexPath selected initally
                guard indexPaths.previous.row != -1 else { return }
                self?.dataSource.toggleUser(at: indexPaths.previous)
                self?.tableView.reloadRows(at: [indexPaths.previous], with: .none)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.nextButtonIsEnabled
            .drive(onNext: { [weak self] in
                self?.nextButton.isEnabled = $0
                self?.nextButton.alpha = 1.0
            })
            .disposed(by: disposeBag)
    }
    
}

extension GuessReplyAuthorViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(RatingScoreTableCell.self, forCellReuseIdentifier: RatingScoreTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UserContactTableCell.self, forCellReuseIdentifier: UserContactTableCell.defaultReusableId)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = UIColor.blue
        nextButton.alpha = 0.5
        nextButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        nextButton.setTitle("Next", for: .normal)
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(60)
        }
    }
    
    
}
