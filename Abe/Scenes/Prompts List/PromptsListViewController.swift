
import Foundation
import RxSwift
import RxCocoa

class PromptsListViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    let dataSource = PromptListDataSource()
    var viewModel: PromptListViewModel!
    var topTableContentOffset: CGFloat = 0
    
    private var tabOptionsView: TabOptionsView!
    private var createPromptButton: UIBarButtonItem!
    private var tableView: UITableView!
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    static func configuredWith(visibility: Visibility,
                               navVc: UINavigationController,
                               contentOffset: CGFloat) -> PromptsListViewController {
        var vc = PromptsListViewController(topContentOffset: contentOffset)
        let router = PromptsRouter(navigationController: navVc)
        let viewModel = PromptListViewModel(router: router)
        vc.setViewModelBinding(model: viewModel!)
        vc.viewModel.inputs.visWhenViewLoadsInput.onNext(visibility)
        vc.topTableContentOffset = contentOffset
        return vc
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(topContentOffset: CGFloat) {
        self.topTableContentOffset = topContentOffset
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupTableView(topOffset: self.topTableContentOffset)
        setupActivityIndicator()
        setupStatusBarBackgroundView()
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

        //MARK: - Output
        viewModel.outputs.promptsToDisplay
            .drive(onNext: { [weak self] in
                self?.dataSource.load(prompts: $0)
                self?.tableView.reloadData()
                
                guard $0.isNotEmpty else { return }
                self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.promptsChangeSet
            .subscribe(onNext: { [weak self] results, changes in
                if let changes = changes {
                    //let initialOffset = self?.tableView.contentOffset.y
                    //let section = PromptListDataSource.Section.publicOnly.rawValue
                    let newPrompts = changes.inserted.map { results[$0] }
                    if newPrompts.count > 0 {
                        self?.dataSource.add(prompts: newPrompts)
                        self?.tableView.reloadData()
                    }
                    
                    let updatedPrompts = changes.updated.map { (prompt: results[$0], index: $0) }
                    if updatedPrompts.count > 0 {
                        updatedPrompts.forEach {
                            self?.dataSource.updatePrompt($0.prompt, at: IndexPath(row: $0.index, section: 0))
                        }
                        self?.tableView.reloadData()
                    }
                    
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
            .drive(onNext: { [weak self] in
                if $0 { self?.activityIndicator.startAnimating() }
                else { self?.activityIndicator.stopAnimating() }
            })
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
    
    fileprivate func setupTableView(topOffset: CGFloat) {
        //MARK: - tableView Properties
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(PromptTableCell.self, forCellReuseIdentifier: PromptTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(self.topTableContentOffset, 0, 0, 0)
        //tableView.refreshControl = UIRefreshControl()
        tableView.dataSource = dataSource
        
        //MARK: - tableView Constraints
        view.addSubview(tableView)
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
    
    private func setupStatusBarBackgroundView() {
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = UIColor.white
        view.addSubview(statusBarView)
    }
    
}



