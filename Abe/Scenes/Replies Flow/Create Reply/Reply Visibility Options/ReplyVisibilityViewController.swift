
import Foundation
import RxSwift
import RxDataSources
import Action

class ReplyVisibilityViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let dataSource = ReplyVisibilityDataSource()
    var viewModel: ReplyVisibilityViewModel!
    
    var publicButton: UIButton!
    var tableView: UITableView!
    var individualContactsTableView: UITableView!
    var createReplyButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!

    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupPublicButton()
        setupTableView()
        setupCreateButton()
        setupCancelButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppearInput.onNext(())
    }
   
    deinit { print("reply options deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        createReplyButton.rx.tap.asDriver()
            .drive(viewModel.inputs.createButtonTappedInput)
            .disposed(by: disposeBag)
        
        publicButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.publicButtonTappedInput)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .map { [weak self] in
                print("status: \(String(describing: self?.dataSource.contactViewModelAt(indexPath: $0)?.isSelected))")
                return self?.dataSource.contactViewModelAt(indexPath: $0)
            }.unwrap()
            .bind(to: viewModel.inputs.selectedUserInput)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .bind(to: viewModel.inputs.selectedIndexPathInput)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.createButtonEnabled
            .subscribe(onNext: { [weak self] in
                self?.createReplyButton.isEnabled = $0
                self?.createReplyButton.style = $0 ? UIBarButtonItemStyle.done : UIBarButtonItemStyle.plain
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.latestIndexPath
            .drive(onNext: { [weak self] in
                self?.dataSource.toggleContact(at: $0)
                self?.tableView.reloadRows(at: [$0], with: .none)
                self?.publicButton.backgroundColor = UIColor.white
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.publicButtonColor
            .drive(onNext: { [weak self] in
                self?.publicButton.backgroundColor = $0
                self?.dataSource.toggleAll(shouldSelect: false)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.selectAllContacts
            .drive(onNext: { [weak self] in
                self?.dataSource.toggleAll(shouldSelect: true)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.individualContacts
            .drive(onNext: { [weak self] (users) in
                self?.dataSource.loadIndividualContacts(contacts: users)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.errorTracker
            .drive(onNext: { [weak self] (error) in
                self?.showError(error)
            })
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
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(publicButton.snp.bottom).offset(10)
        }
    }
    
    private func setupCreateButton() {
        createReplyButton = UIBarButtonItem(title: "Create", style: .done, target: nil, action: nil)
        createReplyButton.isEnabled = false
        createReplyButton.style = UIBarButtonItemStyle.plain
        self.navigationItem.rightBarButtonItem = createReplyButton
    }
    
    private func setupPublicButton() {
        publicButton = UIButton()
        publicButton.backgroundColor = UIColor.blue
        publicButton.alpha = 0.5
        publicButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        publicButton.setTitle("Public", for: .normal)
        publicButton.titleLabel?.textColor = UIColor.blue
        publicButton.backgroundColor = UIColor.white
        
        view.addSubview(publicButton)
        publicButton.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view).offset(100)
            make.height.equalTo(60)
        }
    }
    
    
}

//        tableView.rx.itemSelected.asObservable()
//            .subscribe(onNext: { [weak self] indexPath in
//                guard let section = ReplyVisibilityDataSource.Section(rawValue: indexPath.section) else { fatalError() }
//                switch section {
//                case .generalVisibility:
//                    //Adjust Individual Contacts Section Header
//                    self?.dataSource.updateGeneralVisibilitySelectedStatus(at: indexPath)
//                    guard let viewModel = self?.dataSource.generalVisAtIndexPath(indexPath)
//                        else { return }
//                    self?.viewModel.inputs.generalVisibilitySelected.onNext(viewModel.visibility)
//                    self?.viewModel.inputs.selectedContact.onNext((nil, nil, true))
//                    self?.tableView.reloadData()
//                case .individualContacts:
//                    self?.dataSource.updateContactSelectedStatus(at: indexPath)
//                    //self?.dataSource.deselectAllInSection(section: .generalVisibility)
//                    guard let viewModel = self?.dataSource.contactViewModelAt(indexPath: indexPath)
//                        else { return }
//                    self?.viewModel.inputs.selectedContact.onNext((viewModel.user, viewModel.isSelected, false))
//                    self?.viewModel.inputs.generalVisibilitySelected.onNext(.individualContacts)
//                    self?.tableView.reloadData()
//                }
//            })
//            .disposed(by: disposeBag)


//            .subscribe(onNext: { [weak self] (selectedContacts) in
//                if selectedContacts.isEmpty {
//                    //Adjust Individual Contacts Section Header
//                    //self?.dataSource.selectGeneralVisibility(.all)
////                    self?.viewModel.inputs.generalVisibilitySelected.onNext(.all)
//                } else {
//                    self?.dataSource.deselectAllInSection(section: .generalVisibility)
//                    //self?.viewModel.inputs.generalVisibilitySelected.onNext(.individualContacts)
//                }
//            })
//            .disposed(by: disposeBag)
