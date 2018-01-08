
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

public final class ReplyCellViewModel {
    
    //MARK: - Inputs
    let reply: AnyObserver<PromptReply>
    
    //MARK: - Output
    let body: Driver<String>
    let name: Driver<String>
    let scoreCellViewModels:  Driver<[ScoreCellViewModel]>

    init() {
        guard let user = Application.shared.currentUser.value else { fatalError() }
        
        let _reply = PublishSubject<PromptReply>()
        self.reply = _reply.asObserver()
        
        self.body = _reply.asObservable()
            .map { $0.body }
            .asDriver(onErrorJustReturn: "")
        
        self.name = _reply.asObservable()
            .map { $0.fetchCastedScoreIfExists(for: user.id) }
            .map {
                switch $0.reply.visibility {
                case "all":
                    return ($0.score != nil) ? $0.reply.user!.name : "Someone said..."
                case "contacts":
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

final class ReplyTableCell: UITableViewCell, ValueCell {

    typealias Value = PromptReply
    static var defaultReusableId: String = "ReplyTableCell"
    private(set) var disposeBag = DisposeBag()
    fileprivate let viewModel = ReplyCellViewModel()
    var collectionView: UICollectionView!
    
    // MARK: - Properties
    fileprivate var containerView: UIView!
    fileprivate var replyBodyLabel: UILabel!
    
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
    }
    
    func configureWith(value: PromptReply) {
        viewModel.reply.onNext(value)
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
            make.center.equalTo(containerView.snp.center)
        }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: PointsGridLayout())
        collectionView.backgroundColor = UIColor.orange
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ScoreCollectionCell.self, forCellWithReuseIdentifier: ScoreCollectionCell.reuseIdentifier)
        
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(containerView)
            make.height.equalTo(60)
        }
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
}


