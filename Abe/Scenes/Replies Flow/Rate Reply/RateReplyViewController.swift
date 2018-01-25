
import Foundation
import RxSwift

class RateReplyViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    let dataSource = RatingScoreDataSource()
    var viewModel: RateReplyViewModel!
    private var nextButton: UIButton!
    
    var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        setupTableView()
        setupNextButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewWillAppearInput.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit { print("rate reply deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        tableView.rx.itemSelected.asObservable()
            .distinctUntilChanged()
            .map { [weak self] in self?.dataSource.rating($0) }.unwrap()
            .bind(to: viewModel.inputs.selectedScoreInput)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(to: viewModel.inputs.nextButtonTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.ratingScores
            .drive(onNext: { [weak self] in
                self?.dataSource.loadRatings(ratings: $0)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.previousAndCurrentScore
            .subscribe(onNext: { [weak self] (inputs) in
                let prevIndex = IndexPath(row: inputs.previous.value - 1, section: 0)
                let currIndex = IndexPath(row: inputs.current.value - 1, section: 0)
                self?.dataSource.toggleRating(at: currIndex)
                self?.tableView.reloadRows(at: [currIndex], with: .none)
               
                guard prevIndex.row != -1 else { return }
                self?.dataSource.toggleRating(at: prevIndex)
                self?.tableView.reloadRows(at: [prevIndex], with: .none)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.nextButtonIsEnabled
            .drive(onNext: { [weak self] in
                self?.nextButton.isEnabled = $0
                self?.nextButton.alpha = 1.0
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.nextButtonTitle
            .drive(nextButton.rx.title())
            .disposed(by: disposeBag)
    }
    
}

extension RateReplyViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    fileprivate func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(RatingScoreTableCell.self, forCellReuseIdentifier: RatingScoreTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = UIColor.blue
        nextButton.alpha = 0.5
        nextButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(60)
        }
    }
    
    
}
