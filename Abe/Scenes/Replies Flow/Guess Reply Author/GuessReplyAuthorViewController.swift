
import Foundation
import Foundation
import RxSwift

class GuessReplyAuthorViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: GuessReplyAuthorViewModel!
    private let dataSource = GuessReplyAuthorDataSource()
    
    private var backAndPagerView: BackButtonPageIndicatorView!
    private var titleLabel: UILabel!
    private var nextButton: UIButton!
    private var searchBar: UISearchBar!
    private var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        setupBackAndPagerView()
        setupTitleLabel()
        setupSearchBar()
        setupTableView()
        setupNextButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //viewModel.inputs.viewWillAppearInput.onNext(())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.resignFirstResponder()
    }
    
    override var inputAccessoryView: UIView? { get { return nextButton } }
    override var canBecomeFirstResponder: Bool { return true }
    deinit { print("wager deinit") }
    
    func bindViewModel() {
        
//MARK: - Input
        backAndPagerView.backButton.rx.tap
            .bind(to: viewModel.inputs.backButtonTappedInput)
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
                if $0.isEmpty {
                    self?.dataSource.resetSearchFilter()
                } else {
                    self?.dataSource.filterUsersFor(searchText: $0)
                }
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
        
        viewModel.outputs.currentPageIndicator
            .drive(onNext: { [weak self] in
                self?.backAndPagerView.pageIndicatorView.currentPage = $0
            })
            .disposed(by: disposeBag)
    }
    
}

extension GuessReplyAuthorViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else { return }
        viewModel.inputs.searchTextInput.onNext(searchText)
    }
    
}

extension GuessReplyAuthorViewController {
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
            make.top.equalTo(searchBar.snp.bottom).offset(10)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = UIColor.blue
        nextButton.alpha = 0.5
        nextButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        nextButton.setTitle("Next", for: .normal)
        nextButton.frame.size.height = 60
    }
    
    private func setupBackAndPagerView() {
        backAndPagerView = BackButtonPageIndicatorView()
        backAndPagerView.setupPageIndicatorView(numberOfPages: 3)
        
        view.addSubview(backAndPagerView)
        backAndPagerView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.top.equalTo(view.snp.top)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = FontBook.BariolBold.of(size: 18)
        let attributedString = NSMutableAttributedString(string: "One of your friends wrote this reply,/n who do you think it is?")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attributedString.length))
        titleLabel.attributedText = attributedString

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backAndPagerView.snp.bottom)
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-40)
        }
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search Contacts"
        searchBar.barTintColor = Palette.faintGrey.color
        searchBar.backgroundColor = UIColor.white
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(50)
        }
    }

}

//    private func setupSearchController() {
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search Contacts"
//        definesPresentationContext = true
//        if #available(iOS 11.0, *) {
//            navigationItem.searchController = searchController
//            navigationController?.navigationBar.prefersLargeTitles = true
//        } else {
//            // Fallback on earlier versions
//        }
//
//    }

