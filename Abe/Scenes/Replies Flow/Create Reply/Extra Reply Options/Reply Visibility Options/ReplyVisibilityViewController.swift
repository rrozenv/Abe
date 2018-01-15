
import Foundation
import RxSwift
import RxDataSources
import Action

class ReplyVisibilityViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let dataSource = ReplyVisibilityDataSource()
    var viewModel: ReplyVisibilityViewModel!
    
    var tableView: UITableView!
    var createReplyButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    
    private var selectedIndividuals = Variable<[User]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCreateButton()
        setupCancelButton()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppear.onNext(())
    }
   
    deinit {
        print("reply options deinit")
    }
    
    func bindViewModel() {
        //MARK: - Input
        createReplyButton.rx.tap.asDriver()
            .drive(viewModel.inputs.createTrigger)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .subscribe(onNext: { indexPath in
                guard let section = ReplyVisibilityDataSource.Section(rawValue: indexPath.section) else { fatalError() }
                switch section {
                case .generalVisibility:
                    //Adjust Individual Contacts Section Header
                    self.dataSource.updateGeneralVisibilitySelectedStatus(at: indexPath)
                    guard let viewModel = self.dataSource.generalVisAtIndexPath(indexPath)
                        else { return }
                    self.viewModel.inputs.generalVisibilitySelected.onNext(viewModel.visibility)
                    self.tableView.reloadData()
                case .individualContacts:
                    self.dataSource.updateContactSelectedStatus(at: indexPath)
                    guard let viewModel = self.dataSource.contactViewModelAt(indexPath: indexPath)
                        else { return }
                    self.viewModel.inputs.selectedContact.onNext((viewModel.user, viewModel.isSelected))
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.generalVisibilityOptions
            .drive(onNext: { [weak self] (options) in
                self?.dataSource.loadGeneralVisibility(options: options)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.currentlySelectedIndividualContacts
            .subscribe(onNext: { (selectedContacts) in
                if selectedContacts.isEmpty {
                    //Adjust Individual Contacts Section Header
                    self.dataSource.selectGeneralVisibility(.all)
                    self.viewModel.inputs.generalVisibilitySelected.onNext(.all)
                } else {
                    self.dataSource.deselectAllInSection(section: .generalVisibility)
                    self.viewModel.inputs.generalVisibilitySelected.onNext(.individualContacts)
                }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.individualContacts
            .drive(onNext: { [weak self] (users) in
                self?.dataSource.loadIndividualContacts(contacts: users)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.didCreateReply
            .drive()
            .disposed(by: disposeBag)
        
    }
    
}

extension ReplyVisibilityViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupCancelButton() {
        backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    fileprivate func setupTableView() {
        //MARK: - tableView Properties
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "vis")
        tableView.register(GeneralVisibilityTableCell.self, forCellReuseIdentifier: GeneralVisibilityTableCell.defaultReusableId)
        tableView.register(UserContactTableCell.self, forCellReuseIdentifier: UserContactTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //MARK: - tableView Constraints
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    fileprivate func setupCreateButton() {
        createReplyButton = UIBarButtonItem(title: "Create", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = createReplyButton
    }
    
    
}
