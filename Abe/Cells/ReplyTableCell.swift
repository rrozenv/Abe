
import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol ReplyTableCellDelegate: class {
    func didSelectScore(scoreViewModel: ScoreCellViewModel, at index: IndexPath)
}

final class ReplyTableCell: UITableViewCell, ValueCell {

    // MARK: - Properties
    typealias Value = PromptReply
    static var defaultReusableId: String = "ReplyTableCell"
    private var disposeBag = DisposeBag()
    private var viewModel: ReplyCellViewModel! {
        didSet { bindViewModel() }
    }
    weak var delegate: ReplyTableCellDelegate?
    
    // MARK: - View Properties
    private var containerView: UIView!
    private var replyBodyLabel: UILabel!
    private var collectionView: UICollectionView!
    
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
        //viewModel = ReplyCellViewModel()
    }
    
    func configureWith(value: PromptReply) {
        replyBodyLabel.text = value.body
        //viewModel.reply.onNext(value)
    }
    
    func bindViewModel() {
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
            .subscribe(onNext: { [weak self] (vm) in
                guard let tableIndex = self?.indexPath, !vm.userDidReply else { return }
                self?.delegate?.didSelectScore(scoreViewModel: vm, at: tableIndex)
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
            make.left.equalTo(containerView.snp.left).offset(20)
        }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: PointsGridLayout())
        collectionView.backgroundColor = UIColor.white
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
        viewModel = ReplyCellViewModel()
    }
    
}

protocol RateReplyTableCellDelegate: class {
    func didSelectRateReply(_ reply: PromptReply, isCurrentUsersFriend: Bool)
    func didSelectViewRatings(_ reply: PromptReply)
}

final class RateReplyTableCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = ReplyViewModel
    static var defaultReusableId: String = "RateReplyTableCell"
    private var disposeBag = DisposeBag()
    weak var delegate: RateReplyTableCellDelegate?
    
    // MARK: - View Properties
    private var containerView: UIView!
    private var replyHeaderView: ReplyHeaderView!
    private var rateReplyButton: UIButton!
    private var ratingsSummaryButton: UIButton!
    
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
        self.selectionStyle = .none
        setupContainerView()
        setupReplyHeaderView()
        setupRateReplyButton()
        setupStackView()
        setupViewRatingsButton()
    }
    
    func configureWith(value: ReplyViewModel) {
//        guard let user = AppController.shared.currentUser.value else { fatalError() }
//        if value.reply.user?.id == user.id { hideRateButton() }
        replyHeaderView.nameLabel.text = value.isUnlocked ? value.reply.user?.name : "Identity Locked"
        replyHeaderView.nameSubLabel.text = value.isCurrentUsersFriend ? "From Contacts" : ""
        replyHeaderView.replyBodyLabel.text = value.reply.body
        //rateReplyButton.isHidden = value.ratingScore == nil ? false : true
        ratingsSummaryButton.isHidden = value.isUnlocked ? false : true
        rateReplyButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.delegate?.didSelectRateReply(value.reply,
                                                   isCurrentUsersFriend: value.isCurrentUsersFriend)
            })
            .disposed(by: disposeBag)
        ratingsSummaryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.delegate?.didSelectViewRatings(value.reply)
            })
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        rateReplyButton.isHidden = false
        ratingsSummaryButton.isHidden = false
    }
    
    func hideRateButton() {
        ratingsSummaryButton.isHidden = true
        rateReplyButton.isHidden = true
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 2.0
        containerView.dropShadow()
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsetsMake(6, 0, 0, 0))
//            make.left.equalTo(contentView).offset(26)
//            make.right.equalTo(contentView).offset(-26)
//            make.top.equalTo(contentView).offset(16)
//            make.bottom.equalTo(contentView)
        }
    }
    
    private func setupStackView() {
        let views: [UIView] = [replyHeaderView, rateReplyButton]
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.layer.masksToBounds = true
        stackView.spacing = 0.0
        stackView.axis = .vertical
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
    private func setupRateReplyButton() {
        rateReplyButton = UIButton()
        rateReplyButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 12)
        rateReplyButton.backgroundColor = Palette.red.color
        rateReplyButton.setTitle("Rate Reply", for: .normal)
        rateReplyButton.contentHorizontalAlignment = .center
        rateReplyButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
    }
    
    private func setupViewRatingsButton() {
        ratingsSummaryButton = UIButton()
        ratingsSummaryButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 12)
        ratingsSummaryButton.layer.masksToBounds = true
        ratingsSummaryButton.backgroundColor = Palette.red.color
        ratingsSummaryButton.setTitle("View Ratings", for: .normal)
        
        containerView.addSubview(ratingsSummaryButton)
        ratingsSummaryButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.edges.equalTo(rateReplyButton)
        }
    }
    
    private func setupReplyHeaderView() {
        replyHeaderView = ReplyHeaderView()
    }

}







