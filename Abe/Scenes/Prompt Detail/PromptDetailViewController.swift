
import Foundation
import RxSwift
import RxDataSources
import Action

class PromptDetailViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: PromptDetailViewModel!
    
    var tableView: UITableView!
    var createReplyButton: UIButton!
    var backButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCreatePromptReplyButton()
        setupCancelButton()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func bindViewModel() {
        //MARK: - Input
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = PromptDetailViewModel.Input(reloadTrigger: viewWillAppear, createReplyTrigger: createReplyButton.rx.tap.asDriver(), backTrigger: backButton.rx.tap.asDriver())
        
        //MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.replies
            .drive(tableView.rx.items) { tableView, index, promptReply in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PromptReplyTableCell.reuseIdentifier) as? PromptReplyTableCell else { fatalError() }
                cell.configure(with: promptReply)
                return cell
            }
            .disposed(by: disposeBag)
        
        output.createReply
            .drive()
            .disposed(by: disposeBag)
        
        output.dismissViewController
            .drive()
            .disposed(by: disposeBag)
    }

}

extension PromptDetailViewController {
    
    fileprivate func setupCancelButton() {
        backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    fileprivate func setupTableView() {
        //MARK: - tableView Properties
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(PromptReplyTableCell.self, forCellReuseIdentifier: PromptReplyTableCell.reuseIdentifier)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //MARK: - tableView Constraints
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    fileprivate func setupCreatePromptReplyButton() {
        //MARK: - createPromptButton Properties
        createReplyButton = UIButton()
        createReplyButton.backgroundColor = UIColor.black
        createReplyButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        createReplyButton.setTitle("Reply", for: .normal)
     
        //MARK: - createPromptButton Constraints
        view.addSubview(createReplyButton)
        createReplyButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(60)
        }
    }
    
    
}
