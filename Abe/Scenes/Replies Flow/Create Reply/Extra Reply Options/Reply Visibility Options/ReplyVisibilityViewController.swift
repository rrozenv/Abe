
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
        tableView.reloadData()
    }
    
    deinit {
        print("reply options deinit")
    }
    
    func bindViewModel() {
        //MARK: - Input
        createReplyButton.rx.tap.asDriver()
            .drive(viewModel.inputs.createTrigger)
            .disposed(by: disposeBag)
        
//        tableView.rx.itemSelected.asObservable()
//            .do(onNext: { (indexPath) in
//                if let cell = self.tableView.cellForRow(at: indexPath) as? UserContactTableCell {
//                    cell.isSelect = !cell.isSelect
//                }
//            })
//            .subscribe(onNext: { [weak self] indexPath in
//                if let cell = self?.tableView.cellForRow(at: indexPath) as? UserContactTableCell {
//                    cell.isSelect = !cell.isSelect
//                }
//            })
//            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(User.self).asDriver()
            .do(onNext: { self.selectedIndividuals.value.append($0) })
            .map { _ in self.selectedIndividuals.value }
            .drive(viewModel.inputs.selectedIndividualContacts)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Visibility.self).asDriver()
            .drive(viewModel.inputs.generalVisibilitySelected)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.generalVisibilityOptions
            .drive(onNext: { [weak self] (options) in
                self?.dataSource.loadGeneralVisibility(options: options)
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
        
//        let output = viewModel.transform(input: input)
//
//        output.visibilityOptions
//            .drive(tableView.rx.items) { tableView, index, visibility in
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: "vis") else { fatalError() }
//                cell.textLabel?.text = visibility.rawValue
//                return cell
//            }
//            .disposed(by: disposeBag)
//
//        output.didCreateReply
//            .subscribe()
//            .disposed(by: disposeBag)
//
//        output.savedContacts
//            .drive()
//            .disposed(by: disposeBag)
//
//        output.loading
//            .drive()
//            .disposed(by: disposeBag)
//
//        output.errors
//            .drive(onNext: { [weak self] error in
//                self?.showError(error)
//            })
//            .disposed(by: disposeBag)
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
        tableView.estimatedRowHeight = 200
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
