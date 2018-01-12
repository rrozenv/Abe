
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
    private var viewModel = ReplyCellViewModel()
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
        //viewModel = ReplyCellViewModel()
    }
    
}






