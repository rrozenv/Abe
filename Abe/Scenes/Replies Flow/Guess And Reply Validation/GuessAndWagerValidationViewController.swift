
import Foundation
import RxSwift
import RxCocoa

final class GuessAndWagerValidationViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: GuessAndWagerValidationViewModel!
    private var replyView: ReplyHeaderView!
    private var guessedUserView: GuessedUserView!
    private var scoresTableView: UITableView!
    private var scoresDataSource = GuessAndReplyValidationDataSource()
    private var doneButton: UIButton!
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        setupGuessedUserView()
        setupReplyView()
        setupTableView()
        setupDoneButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit { print("Add Web Link deinit") }
    
    func bindViewModel() {
        
        //MARK: - Inputs
//        searchButton.rx.tap
//            .throttle(0.5, scheduler: MainScheduler.instance)
//            .bind(to: viewModel.inputs.)
//            .disposed(by: disposeBag)
        
//        actionButtonsView.doneButton.rx.tap
//            .throttle(0.5, scheduler: MainScheduler.instance)
//            .bind(to: viewModel.inputs.doneTappedInput)
//            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.unlockedReply
            .drive(onNext: { [weak self] in
                self?.replyView.populateInfoWith(reply: $0)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isUserCorrect
            .drive(onNext: { [weak self] in
                self?.guessedUserView.nameLabel.text = $0.guessedUser.name
                self?.guessedUserView.nameSubLabel.text = "YOUR GUESS"
                self?.guessedUserView.backgroundColor = $0.isCorrect ? UIColor.green : UIColor.red
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.replyScores
            .drive(onNext: { [weak self] in
                self?.scoresDataSource.loadScores($0)
                self?.scoresTableView.reloadData()
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
        doneButton = UIButton()
        doneButton.backgroundColor = UIColor.green
        doneButton.setTitle("Done", for: .normal)
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    private func setupGuessedUserView() {
        guessedUserView = GuessedUserView()
        
        view.addSubview(guessedUserView)
        guessedUserView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view).inset(20)
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(20)
            make.height.equalTo(120)
        }
    }
    
    private func setupReplyView() {
        replyView = ReplyHeaderView()
    
        view.addSubview(replyView)
        replyView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(guessedUserView.snp.bottom).offset(10)
        }
    }
    
    private func setupTableView() {
        scoresTableView = UITableView(frame: CGRect.zero, style: .grouped)
        scoresTableView.register(RatingScoreTableCell.self, forCellReuseIdentifier: RatingScoreTableCell.defaultReusableId)
        scoresTableView.estimatedRowHeight = 200
        scoresTableView.dataSource = scoresDataSource
        scoresTableView.rowHeight = UITableViewAutomaticDimension
        scoresTableView.register(SavedReplyScoreTableCell.self, forCellReuseIdentifier: SavedReplyScoreTableCell.defaultReusableId)
        
        view.addSubview(scoresTableView)
        scoresTableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(replyView.snp.bottom)
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
