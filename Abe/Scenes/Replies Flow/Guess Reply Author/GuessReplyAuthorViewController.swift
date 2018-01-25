
import Foundation
import Foundation
import RxSwift

class GuessReplyAuthorViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: GuessReplyAuthorViewModel!
    private let dataSource = GuessReplyAuthorDataSource()
    
    private var nextButton: UIButton!
    private var searchController = UISearchController(searchResultsController: nil)
    //private var searchBar: UISearchBar!
    private var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        setupSearchController()
        setupTableView()
        setupNextButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Who do you think made this reply?"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //viewModel.inputs.viewWillAppearInput.onNext(())
    }
    
    deinit { print("wager deinit") }
    
    func bindViewModel() {
        
//MARK: - Input
        searchController.searchBar.rx.cancelButtonClicked
            .bind(to: viewModel.inputs.searchCancelTappedInput)
            .disposed(by: disposeBag)

        tableView.rx.itemSelected.asObservable()
            .map { [weak self] in self?.dataSource.getUser(at: $0) }.unwrap()
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedUserViewModelInput)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(to: viewModel.inputs.nextButtonTappedInput)
            .disposed(by: disposeBag)
        
//MARK: - Output
        viewModel.outputs.allUsersFriends
            .drive(onNext: { [weak self] in
                self?.dataSource.loadUsers(viewModels: $0)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.searchTextObservable
            .subscribe(onNext: { [weak self] in
                self?.dataSource.filterUsersFor(searchText: $0)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.cancelSearchTappedObservable
            .subscribe(onNext: { [weak self] in
                self?.dataSource.resetSearchFilter()
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.previousAndCurrentSelectedUser
            .subscribe(onNext: { [unowned self] (users) in
                if let currIndexPath = self.dataSource.toggleUser(users.current) {
                   self.tableView.reloadRows(at: [currIndexPath], with: .none)
                }
                
                //First value will contain a a defualt user with "id" = 0
                //because there is no previous user selected initally
                guard users.previous.user.id != "0" else { return }
                if let prevIndexPath = self.dataSource.toggleUser(users.previous) {
                    self.tableView.reloadRows(at: [prevIndexPath], with: .none)
                }
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

extension GuessReplyAuthorViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text,
                  !searchText.isEmpty else { return }
        viewModel.inputs.searchTextInput.onNext(searchText)
    }
    
}

extension GuessReplyAuthorViewController {
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(RatingScoreTableCell.self, forCellReuseIdentifier: RatingScoreTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UserContactTableCell.self, forCellReuseIdentifier: UserContactTableCell.defaultReusableId)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalTo(view)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaInsets.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
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
