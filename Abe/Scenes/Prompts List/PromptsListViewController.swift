
import Foundation
import RxSwift
import RxCocoa

class PromptsListViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    let dataSource = PromptListDataSource()
    var viewModel: PromptListViewModel!
    
    private var tabOptionsView: TabOptionsView!
    private var createPromptButton: UIBarButtonItem!
    private var tableView: UITableView!
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupTabOptionsView()
        setupTableView()
        setupCreatePromptButton()
        setupActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit { print("rate reply deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .map { [weak self] in self?.dataSource.promptAtIndexPath($0) }.unwrap()
            .bind(to: viewModel.inputs.promptSelectedInput)
            .disposed(by: disposeBag)
        
        createPromptButton.rx.tap
            .bind(to: viewModel.inputs.createTappedInput)
            .disposed(by: disposeBag)
        
        let publicTapped = tabOptionsView.button(at: 0).rx.tap
            .map { _ in Visibility.all }
            .asDriverOnErrorJustComplete()
        
        let privateTapped = tabOptionsView.button(at: 1).rx.tap
            .map { _ in Visibility.individualContacts }
            .asDriverOnErrorJustComplete()
        
       Observable.of(publicTapped, privateTapped)
            .merge()
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.tabVisSelectedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.tabVisSelected
            .drive(onNext: { [weak self] in
                switch $0 {
                case .all: self?.tabOptionsView.currentTab = 0
                case .individualContacts: self?.tabOptionsView.currentTab = 1
                default: break
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.contactsOnlyPrompts
            .drive(onNext: { [weak self] in
                self?.dataSource.loadContactsOnly(prompts: $0)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.publicPrompts
            .drive(onNext: { [weak self] in
                self?.dataSource.loadPublic(prompts: $0)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.promptsChangeSet
            .subscribe(onNext: { [weak self] results, changes in
                if let changes = changes {
                    //let initialOffset = self?.tableView.contentOffset.y
                    //let section = PromptListDataSource.Section.publicOnly.rawValue
                    let prompts = changes.inserted.map { results[$0] }
                    guard prompts.count > 0 else { return }
                    self?.dataSource.addNewPublic(prompts: prompts)
                    self?.tableView.reloadData()
                    //self?.tableView.scrollToRow(at: IndexPath(row: prompts.count, section: 1), at: .top, animated: false)
                    //self?.tableView.contentOffset.y += initialOffset ?? 0
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.errorTracker
            .drive(onNext: { [weak self] (error) in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.activityIndicator
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
}

extension PromptsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension PromptsListViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupCreatePromptButton() {
        createPromptButton = UIBarButtonItem(title: "Create", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = createPromptButton
    }
    
    private func setupTabOptionsView() {
        tabOptionsView = TabOptionsView(numberOfItems: 2)
        tabOptionsView.setTitleForButton(title: "Public", at: 0)
        tabOptionsView.setTitleForButton(title: "Private", at: 1)
        
        view.addSubview(tabOptionsView)
        tabOptionsView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view.snp.top).offset(64)
            make.height.equalTo(50)
        }
    }
    
    fileprivate func setupTableView() {
        //MARK: - tableView Properties
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(PromptTableCell.self, forCellReuseIdentifier: PromptTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.refreshControl = UIRefreshControl()
        tableView.dataSource = dataSource
        
        //MARK: - tableView Constraints
        view.insertSubview(tableView, belowSubview: tabOptionsView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
        }
    }
    
}



