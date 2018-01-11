
import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

//protocol ReplyCellViewModelInputs {
//    /// Call to configure cell with activity value.
//    var reply: PublishSubject<PromptReply> { get }
//}
//
//protocol ReplyCellViewModelOutputs {
//    /// Emits the backer image url to be displayed.
//    var body: Driver<String> { get }
//}
//
//protocol ReplyCellViewModelType {
//    var inputs: ReplyCellViewModelInputs { get }
//    var outputs: ReplyCellViewModelOutputs { get }
//}

struct ReplyScoreCellViewModel {
    let value: Int
    let reply: PromptReply
    let placeholderImage: UIImage
    let userScore: ReplyScore?
    let percentage: String
}

struct ReplyCellViewModel {
    
    //MARK: - Inputs
    let reply: AnyObserver<PromptReply>
    
    //MARK: - Output
    let body: Driver<String>
    let name: Driver<String>
    let scoreCellViewModels:  Driver<[ScoreCellViewModel]>

    init() {
        guard let user = AppController.shared.currentUser.value else { fatalError() }
        
        let _reply = PublishSubject<PromptReply>()
        self.reply = _reply.asObserver()
        
        self.body = _reply.asObservable()
            .debug()
            .map { $0.body }
            .asDriver(onErrorJustReturn: "")
        
        self.name = _reply.asObservable()
            .map { $0.fetchCastedScoreIfExists(for: user.id) }
            .map {
                guard let visibility = Visibility(rawValue: $0.reply.visibility) else { return "???" }
                switch visibility {
                case .all:
                    return ($0.score != nil) ? $0.reply.user!.name : "Someone said..."
                case .contacts:
                    return ($0.score != nil) ? $0.reply.user!.name : "Someone from contacts said..."
                default: return "???"
                }
            }
            .asDriver(onErrorJustReturn: "")
        
        self.scoreCellViewModels = _reply.asObservable()
            .map { reply in
               return [#imageLiteral(resourceName: "IC_Score_One_Unselected"), #imageLiteral(resourceName: "IC_Score_Two_Unselected"), #imageLiteral(resourceName: "IC_Score_Three_Unselected"), #imageLiteral(resourceName: "IC_Score_Four_Unselected"), #imageLiteral(resourceName: "IC_Score_Five_Unselected")].enumerated().map {
                    let scoreValue = $0.offset + 1
                    let replyScoreIfExists = reply.fetchCastedScoreIfExists(for: user.id)
                    let userDidReply = replyScoreIfExists.score != nil ? true : false
                    let percentage = "\(reply.percentageOfVotesCastesFor(scoreValue: scoreValue))"
                    return ScoreCellViewModel(value: scoreValue,
                                              reply: reply,
                                              userDidReply: userDidReply,
                                              placeholderImage: $0.element,
                                              userScore: replyScoreIfExists.score,
                                              percentage: percentage)
                }
            }
            .asDriver(onErrorJustReturn: [])
        
    }
    
}

protocol ReplyTableCellDelegate: class {
    func didSelectScore(scoreViewModel: ScoreCellViewModel, at index: IndexPath)
}

final class ReplyTableCell: UITableViewCell, ValueCell {

    typealias Value = PromptReply
    static var defaultReusableId: String = "ReplyTableCell"
    
    private(set) var disposeBag = DisposeBag()
    fileprivate var viewModel = ReplyCellViewModel()
    var collectionView: UICollectionView!
    
    private var replyScoresDataSource = ReplyScoresDataSource()
    weak var delegate: ReplyTableCellDelegate?
    
    // MARK: - Properties
    private var containerView: UIView!
    private var replyBodyLabel: UILabel!
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        setupContainerView()
        setupCollectionView()
        setupTitleLabel()
    }
    
    func configureWith(value: PromptReply) {
        bindViewModel()
        viewModel.reply.onNext(value)
    }
    
    private func bindViewModel() {
        viewModel.body
            .drive(replyBodyLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.scoreCellViewModels
            .drive(collectionView.rx.items) { collView, index, vm in
                guard let cell = collView.dequeueReusableCell(withReuseIdentifier: ScoreCollectionCell.reuseIdentifier, for: IndexPath(row: index, section: 0)) as? ScoreCollectionCell else { fatalError() }
                cell.configure(with: vm)
                return cell
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(ScoreCellViewModel.self)
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (vm) in
                guard let tableIndex = self.indexPath, !vm.userDidReply else { return }
                self.delegate?.didSelectScore(scoreViewModel: vm, at: tableIndex)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
            make.height.equalTo(100)
        }
    }
    
    private func setupTitleLabel() {
        replyBodyLabel = UILabel()
        
        containerView.addSubview(replyBodyLabel)
        replyBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        replyBodyLabel.snp.makeConstraints { (make) in
            //make.bottom.equalTo(collectionView.snp.top).offset(-5)
            make.top.equalTo(containerView.snp.top)
            //make.left.equalTo(containerView.snp.left).offset(10)
        }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: PointsGridLayout())
        collectionView.backgroundColor = UIColor.orange
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ScoreCollectionCell.self, forCellWithReuseIdentifier: ScoreCollectionCell.defaultReusableId)
        
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(containerView)
            make.height.equalTo(60)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        replyScoresDataSource = ReplyScoresDataSource()
        //viewModel = ReplyCellViewModel()
    }
    
}

final class SavedReplyScoreTableCell: UITableViewCell, ValueCell {
    
    typealias Value = ReplyScore
    static var defaultReusableId: String = "SavedReplyScoreTableCell"
    private(set) var disposeBag = DisposeBag()
    
    // MARK: - Properties
    fileprivate var containerView: UIView!
    fileprivate var scoreLabel: UILabel!
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        setupContainerView()
        setupTitleLabel()
    }
    
    func configureWith(value: ReplyScore) {
        scoreLabel.text = "\(value.score)"
    }

    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
            make.height.equalTo(80)
        }
    }
    
    private func setupTitleLabel() {
        scoreLabel = UILabel()
        
        containerView.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.snp.makeConstraints { (make) in
            //make.bottom.equalTo(collectionView.snp.top).offset(-5)
            make.center.equalTo(containerView.snp.center)
            //make.left.equalTo(containerView.snp.left).offset(10)
        }
    }
    
}

struct RepliesEmptyStateViewModel {
    let filterOption: FilterOption
    let userDidReply: Bool
}

final class RepliesEmptyCell: UITableViewCell, ValueCell {

    typealias Value = RepliesEmptyStateViewModel
    static var defaultReusableId: String = "RepliesEmptyCell"
    private(set) var disposeBag = DisposeBag()
    
    // MARK: - Properties
    fileprivate var containerView: UIView!
    fileprivate var mainLabel: UILabel!
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        setupContainerView()
        setupTitleLabel()
    }
    
    func configureWith(value: RepliesEmptyStateViewModel) {
        guard !value.userDidReply else { configureUserDidNotReplyState() ; return }
        switch value.filterOption {
        case .locked:
            mainLabel.text = "You have no LOCKED unread replies."
        case .unlocked:
            mainLabel.text = "You have no UNLOCKED replies."
        case .myReply:
            mainLabel.text = "No one has voted on your reply yet."
        }
    }
    
    private func configureUserDidNotReplyState() {
        mainLabel.text = "You must make your reply FIRST"
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
            make.height.equalTo(200)
        }
    }
    
    private func setupTitleLabel() {
        mainLabel = UILabel()
        
        containerView.addSubview(mainLabel)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.snp.makeConstraints { (make) in
            //make.bottom.equalTo(collectionView.snp.top).offset(-5)
            make.center.equalTo(containerView.snp.center)
            //make.left.equalTo(containerView.snp.left).offset(10)
        }
    }
    
}


