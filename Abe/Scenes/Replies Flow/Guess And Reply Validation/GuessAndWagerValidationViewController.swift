
import Foundation
import RxSwift
import RxCocoa

final class GuessAndWagerValidationViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: GuessAndWagerValidationViewModel!
    
    private var doneButton: UIButton!
    private var guessedUserView: GuessedUserView!
    private var dividerView: UIView!
    private var headerStackView: UIStackView!
    private var tableView: UITableView!
    private var dataSource = GuessAndReplyValidationDataSource()
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        setupDoneButton()
        setupHeaderStackView()
        //setupReplyView()
        setupTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ViewDidLoadInput is done in InputWagerRouter
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit { print("Validation deinit") }
    
    func bindViewModel() {
        
        //MARK: - Inputs
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.doneButtonTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.isUserCorrect
            .drive(onNext: { [weak self] in
                self?.guessedUserView.nameLabel.text = $0.guessedUser.name
                self?.guessedUserView.nameSubLabel.text = "YOUR GUESS"
                self?.guessedUserView.backgroundColor = $0.isCorrect ? UIColor.green : UIColor.red
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isGuessedUserHidden
            .drive(guessedUserView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.unlockedReplyViewModel
            .drive(onNext: { [weak self] in
                let section = GuessAndReplyValidationDataSource.Section.reply.rawValue
                self?.dataSource.loadUnlockedReply(viewModel: $0)
                self?.tableView.reloadSections([section], animationStyle: .none)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.percentageGraphInfo
            .drive(onNext: { [weak self] in
                let section = GuessAndReplyValidationDataSource.Section.percentageGraph.rawValue
                self?.dataSource.loadPercentageGraph(viewModel: $0)
                self?.tableView.reloadSections([section], animationStyle: .none)
            })
            .disposed(by: disposeBag)
    
        viewModel.outputs.replyScores
            .drive(onNext: { [weak self] in
                let section = GuessAndReplyValidationDataSource.Section.ratingScores.rawValue
                self?.dataSource.loadScores($0)
                self?.tableView.reloadSections([section], animationStyle: .none)
            })
            .disposed(by: disposeBag)
        
//        viewModel.outputs.activityIndicator
//            .drive(activityIndicator.rx.isAnimating)
//            .disposed(by: disposeBag)
//
//        viewModel.outputs.activityIndicator
//            .drive(onNext: { [weak self] in
//                self?.actionButtonsView.isHidden = $0 ? true : false
//            })
//            .disposed(by: disposeBag)
    }
    
    private func handleError(_ error: Error) {
        switch error {
        case is WebLinkThumbnailServiceError:
            print("missing info!")
        default: break
        }
    }
    
    private func setupDoneButton() {
        doneButton = UIButton.cancelButton(image: #imageLiteral(resourceName: "IC_BlackX"))
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
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
    
    private func setupHeaderStackView() {
        guessedUserView = GuessedUserView(height: 80)
        
        dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        dividerView.snp.makeConstraints { (make) in make.height.equalTo(2) }
        
        let views: [UIView] = [guessedUserView, dividerView]
        headerStackView = UIStackView(arrangedSubviews: views)
        headerStackView.axis = .vertical
        headerStackView.spacing = 10.0
        
        view.addSubview(headerStackView)
        headerStackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view).inset(20)
            make.top.equalTo(doneButton.snp.bottom).offset(20)
        }
    }

    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(RatingScoreTableCell.self, forCellReuseIdentifier: RatingScoreTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.dataSource = dataSource
        //tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(RateReplyTableCell.self, forCellReuseIdentifier: RateReplyTableCell.defaultReusableId)
        tableView.register(RatingPercentageGraphCell.self, forCellReuseIdentifier: RatingPercentageGraphCell.defaultReusableId)
        tableView.register(SavedReplyScoreTableCell.self, forCellReuseIdentifier: SavedReplyScoreTableCell.defaultReusableId)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(headerStackView.snp.bottom)
        }
    }
    
    private func setupLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
        }
    }
    
}

extension GuessAndWagerValidationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}
