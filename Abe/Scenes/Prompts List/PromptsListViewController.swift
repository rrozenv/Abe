
import Foundation
import RxSwift
import RealmSwift
import RxDataSources
import Action
import RxRealm
import RxRealmDataSources
//import NSObject_Rx

import RxSwift
import RxCocoa

class PromptsListViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    var viewModel: PromptsListViewModel!
    var tableView: UITableView!
    var createPromptButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCreatePromptButton()
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)

        let pull = tableView.refreshControl!.rx
            .controlEvent(.valueChanged)
            .asDriver()
        
        let input =
            PromptsListViewModel
            .Input(createPostTrigger: createPromptButton.rx.tap.asDriver(),
                   selection: tableView.rx.realmModelSelected(Prompt.self).asDriver())
        
        //MARK: - Output
        let output = viewModel.transform(input: input)
        
        let dataSource = RxTableViewRealmDataSource<Prompt>(cellIdentifier: PromptTableCell.reuseIdentifier, cellType: PromptTableCell.self) {cell, indexPath, prompt in
            cell.configure(with: prompt)
        }
        
        output.posts
            .bind(to: tableView.rx.realmChanges(dataSource))
            .disposed(by: disposeBag)

        pull.drive(onNext: { [weak self] in
            self?.tableView.reloadData()
            self?.tableView.refreshControl?.endRefreshing()
        })
        .disposed(by: disposeBag)
        
        output.fetching
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        output.createPrompt
            .drive()
            .disposed(by: disposeBag)
        
        output.selectedPrompt
            .drive()
            .disposed(by: disposeBag)
        
        output.error
            .drive()
            .disposed(by: disposeBag)

    }
    
}

extension PromptsListViewController {
    
    fileprivate func setupCreatePromptButton() {
        createPromptButton = UIBarButtonItem(title: "Create", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = createPromptButton
    }
    
    fileprivate func setupTableView() {
        //MARK: - tableView Properties
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(PromptTableCell.self, forCellReuseIdentifier: PromptTableCell.reuseIdentifier)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.refreshControl = UIRefreshControl()
        
        //MARK: - tableView Constraints
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
}




