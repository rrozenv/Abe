
import Foundation
import RxSwift
import RxDataSources
import Action

class ReplyVisibilityViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: ReplyVisibilityViewModel!
    private let dataSource = ReplyVisibilityDataSource()
    
    private var publicButton: UIButton!
    private var tableView: UITableView!
    private var createReplyButton: UIButton!
    private var selectAllContactsButton: UIButton!
    private var contactsTableHeaderView: ContactsTableHeaderView!
    private var publicVisiblitySectionView: PublicVisibilitySectionHeaderView!
    private var searchBar: UISearchBar!
    private var backButton: UIButton!
    private var isAllContactsSelected = Variable<Bool>(true)

    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupBackButton()
        //setupPublicButton()
        //setupSearchBar()
        setupTableView()
        setupCreateButton()
        //setupCancelButton()
        setupContatsTableHeaderView()
        setupPublicVisibilitySectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppearInput.onNext(())
    }
   
    override var inputAccessoryView: UIView? { get { return createReplyButton } }
    override var canBecomeFirstResponder: Bool { return true }
    deinit { print("reply options deinit") }
    
    func bindViewModel() {
        
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        createReplyButton.rx.tap.asDriver()
            .debug()
            .drive(viewModel.inputs.createButtonTappedInput)
            .disposed(by: disposeBag)
        
        publicVisiblitySectionView.actionButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.publicButtonTappedInput)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .map { [unowned self] in
                (self.dataSource.getUser(at: $0)!, $0) }
            .bind(to: viewModel.inputs.selectedUserAndIndexPathInput)
            .disposed(by: disposeBag)
        
        contactsTableHeaderView.actionButton.rx.tap.asObservable()
            //.scan(false) { lastState, _ in return !lastState }
            .withLatestFrom(isAllContactsSelected.asObservable())
            .bind(to: viewModel.inputs.selectedAllContactsTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.currentIndividualNumbers
            .drive(onNext: {
                $0.forEach { print($0) }
                print("------")
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.searchTextObservable
            .subscribe(onNext: { [weak self] in
                if $0.isEmpty {
                    self?.dataSource.resetSearchFilter()
                    self?.contactsTableHeaderView.actionButton.isHidden = false
                } else {
                    self?.dataSource.filterUsersFor(searchText: $0)
                    self?.contactsTableHeaderView.actionButton.isHidden = true
                }
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.latestUserAndIndexPath
            .drive(onNext: { [weak self] in
                let _ = self?.dataSource.toggleUser($0.user)
                self?.tableView.reloadRows(at: [$0.indexPath], with: .none)
                self?.publicVisiblitySectionView.containerView.backgroundColor = UIColor.white
                
                self?.updateContactsHeaderView()
                self?.setCreateButtonEnabledStatus(publicVisIsSelected: false)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.publicButtonTapped
            .drive(onNext: { [weak self] in
                self?.publicVisiblitySectionView.containerView.backgroundColor = UIColor.green
                self?.dataSource.toggleAll(shouldSelect: false)
                self?.tableView.reloadData()
                
                self?.updateContactsHeaderView()
                self?.setCreateButtonEnabledStatus(publicVisIsSelected: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.selectAllContacts
            .drive(onNext: { [weak self] in
                self?.dataSource.toggleAll(shouldSelect: $0)
                self?.tableView.reloadData()
                self?.publicVisiblitySectionView.containerView.backgroundColor = UIColor.white
                
                self?.updateContactsHeaderView()
                self?.setCreateButtonEnabledStatus(publicVisIsSelected: false)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.individualContacts
            .drive(onNext: { [weak self] (users) in
                self?.dataSource.loadUsers(viewModels: users)
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

extension ReplyVisibilityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = ReplyVisibilityDataSource.Section(rawValue: section) else { fatalError("Unexpected Section") }
        switch section {
        case .publicVisibility: return publicVisiblitySectionView
        case .contacts: return contactsTableHeaderView
        }
    }
    
}

extension ReplyVisibilityViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else { return }
        viewModel.inputs.searchTextInput.onNext(searchText)
    }
    
}

extension ReplyVisibilityViewController {
    
    private func setCreateButtonEnabledStatus(publicVisIsSelected: Bool) {
        guard !publicVisIsSelected else {
            self.createReplyButton.isHidden = false
            return
        }
        let selectedCount = self.dataSource.selectedCount()
        //self.createReplyButton.isEnabled = selectedCount > 0 ? true : false
        self.createReplyButton.isHidden = selectedCount > 0 ? false : true
    }
    
    private func updateContactsHeaderView() {
        let selectedCount = self.dataSource.selectedCount()
        let totalCount = self.dataSource.totalCount()
        if selectedCount > 0 && totalCount == selectedCount {
            self.contactsTableHeaderView.actionButton.setTitle("Deselect All", for: .normal)
            self.contactsTableHeaderView.titleLabel.text = "\(String(describing: selectedCount)) Selected"
            self.isAllContactsSelected.value = false
        } else if selectedCount > 0 {
            self.contactsTableHeaderView.actionButton.setTitle("Select All", for: .normal)
            self.contactsTableHeaderView.titleLabel.text = "\(String(describing: selectedCount)) Selected"
            self.isAllContactsSelected.value = true
        } else {
            self.contactsTableHeaderView.actionButton.setTitle("Select All", for: .normal)
            self.contactsTableHeaderView.titleLabel.text = "Select From Contacts"
            self.isAllContactsSelected.value = true
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
//    private func setupCancelButton() {
//        backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
//        self.navigationItem.leftBarButtonItem = backButton
//    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "vis")
        tableView.register(GeneralVisibilityTableCell.self, forCellReuseIdentifier: GeneralVisibilityTableCell.defaultReusableId)
        tableView.register(UserContactTableCell.self, forCellReuseIdentifier: UserContactTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(backButton.snp.bottom).offset(6)
        }
    }
    
    private func setupCreateButton() {
        createReplyButton = UIButton()
        createReplyButton.isHidden = true
        createReplyButton.setTitle("Create", for: .normal)
        createReplyButton.backgroundColor = Palette.brightYellow.color
        createReplyButton.setTitleColor(Palette.darkYellow.color, for: .normal)
        createReplyButton.titleLabel?.font = FontBook.BariolBold.of(size: 14)
        createReplyButton.frame.size.height = 50
        createReplyButton.frame.size.width = view.frame.size.width
    }
    
    private func setupPublicVisibilitySectionView() {
        publicVisiblitySectionView = PublicVisibilitySectionHeaderView()
        publicVisiblitySectionView.titleLabel.text = "Who will be able to see & reply to your post?"
        publicVisiblitySectionView.centerDividerLabel.text = "or"
        publicVisiblitySectionView.imageNameSublabelView.nameLabel.text = "EVERYONE"
        publicVisiblitySectionView.imageNameSublabelView.nameSubLabel.text = "Both friends & Strangers"
    }
    
//    private func setupPublicButton() {
//        publicButton = UIButton()
//        publicButton.backgroundColor = UIColor.blue
//        publicButton.alpha = 0.5
//        publicButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
//        publicButton.setTitle("Public", for: .normal)
//        publicButton.setTitleColor(UIColor.blue, for: .normal)
//        publicButton.titleLabel?.textColor = UIColor.blue
//        publicButton.backgroundColor = UIColor.white
//
//        view.addSubview(publicButton)
//        publicButton.snp.makeConstraints { (make) in
//            make.left.right.equalTo(view)
//            make.top.equalTo(view).offset(100)
//            make.height.equalTo(60)
//        }
//    }
    
    private func setupContatsTableHeaderView() {
        contactsTableHeaderView = ContactsTableHeaderView()
        contactsTableHeaderView.actionButton.setTitle("Select All", for: .normal)
        contactsTableHeaderView.titleLabel.text = "Select From Contacts"
        contactsTableHeaderView.searchBar.delegate = self
    }
    
    private func setupBackButton() {
        backButton = UIButton.backButton(image: #imageLiteral(resourceName: "IC_BackArrow_Black"))
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            if #available(iOS 11.0, *) {
                if UIDevice.iPhoneX {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-44)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-20)
                }
            } else {
                make.top.equalTo(view.snp.top)
            }
        }
    }
    
//    private func setupSearchBar() {
//        searchBar = UISearchBar()
//        searchBar.searchBarStyle = .minimal
//        searchBar.placeholder = "Search Contacts"
//        searchBar.barTintColor = Palette.faintGrey.color
//        searchBar.backgroundColor = UIColor.white
//        searchBar.delegate = self
//
//        view.addSubview(searchBar)
//        searchBar.snp.makeConstraints { (make) in
//            make.top.equalTo(publicButton.snp.bottom).offset(10)
//            make.left.equalTo(view).offset(20)
//            make.right.equalTo(view).offset(-20)
//            make.height.equalTo(50)
//        }
//    }
    
}

