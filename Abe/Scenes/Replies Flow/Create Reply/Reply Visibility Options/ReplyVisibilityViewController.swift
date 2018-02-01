
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
    private var createReplyButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!
    private var selectAllContactsButton: UIButton!
    private var contactsTableHeaderView: ContactsTableHeaderView!
    private var isAllContactsSelected = Variable<Bool>(true)

    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupPublicButton()
        setupTableView()
        setupCreateButton()
        setupCancelButton()
        setupContatsTableHeaderView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppearInput.onNext(())
    }
   
    deinit { print("reply options deinit") }
    
    func bindViewModel() {
        
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        createReplyButton.rx.tap.asDriver()
            .drive(viewModel.inputs.createButtonTappedInput)
            .disposed(by: disposeBag)
        
        publicButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.publicButtonTappedInput)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .map { [unowned self] in
                (self.dataSource.contactViewModelAt(indexPath: $0)!, $0) }
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
        
        viewModel.outputs.latestUserAndIndexPath
            .drive(onNext: { [weak self] in
                self?.dataSource.toggleContact(at: $0.indexPath)
                self?.tableView.reloadRows(at: [$0.indexPath], with: .none)
                self?.publicButton.backgroundColor = UIColor.white
                
                self?.updateContactsHeaderView()
                self?.setCreateButtonEnabledStatus(publicVisIsSelected: false)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.publicButtonTapped
            .drive(onNext: { [weak self] in
                self?.publicButton.backgroundColor = UIColor.green
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
                self?.publicButton.backgroundColor = UIColor.white
                
                self?.updateContactsHeaderView()
                self?.setCreateButtonEnabledStatus(publicVisIsSelected: false)
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

extension ReplyVisibilityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return contactsTableHeaderView
    }
    
}

extension ReplyVisibilityViewController {
    
    private func setCreateButtonEnabledStatus(publicVisIsSelected: Bool) {
        guard !publicVisIsSelected else {
            self.createReplyButton.isEnabled = true
            self.createReplyButton.style = UIBarButtonItemStyle.done
            return
        }
        let selectedCount = self.dataSource.selectedCount()
        self.createReplyButton.isEnabled = selectedCount > 0 ? true : false
        self.createReplyButton.style = selectedCount > 0 ? UIBarButtonItemStyle.done : UIBarButtonItemStyle.plain
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
    
    private func setupCancelButton() {
        backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "vis")
        tableView.register(GeneralVisibilityTableCell.self, forCellReuseIdentifier: GeneralVisibilityTableCell.defaultReusableId)
        tableView.register(UserContactTableCell.self, forCellReuseIdentifier: UserContactTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        
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
    
    private func setupContatsTableHeaderView() {
        contactsTableHeaderView = ContactsTableHeaderView()
        contactsTableHeaderView.actionButton.setTitle("Select All", for: .normal)
        contactsTableHeaderView.titleLabel.text = "Select From Contacts"
    }
    
}

