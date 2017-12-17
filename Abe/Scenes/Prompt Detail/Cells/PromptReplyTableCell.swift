
import Foundation
import UIKit
import SnapKit

protocol PromptTableCellDelegate: class {
    func didSelectScore(_ score: String, replyId: String)
}

final class PromptReplyTableCell: UITableViewCell {
    
    enum Score {
        case one(UIImage, String)
        case two(UIImage, String)
        case three(UIImage, String)
        case four(UIImage, String)
        case five(UIImage, String)
        
        var getImage: UIImage {
            switch self {
            case .one(let image, _):
                return image
            case .two(let image, _):
                return image
            case .three(let image, _):
                return image
            case .four(let image, _):
                return image
            case .five(let image, _):
                return image
            }
        }
        
        var getScore: String {
            switch self {
            case .one(_, let score):
                return score
            case .two(_, let score):
                return score
            case .three(_, let score):
                return score
            case .four(_, let score):
                return score
            case .five(_, let score):
                return score
            }
        }
        
        static func createScores() -> [Score] {
            return [Score.one(#imageLiteral(resourceName: "IC_Score_One_Unselected"), "1"), Score.two(#imageLiteral(resourceName: "IC_Score_Two_Unselected"), "2"), Score.three(#imageLiteral(resourceName: "IC_Score_Three_Unselected"), "3"), Score.four(#imageLiteral(resourceName: "IC_Score_Four_Unselected"), "4"), Score.five(#imageLiteral(resourceName: "IC_Score_Five_Unselected"), "5")]
        }
    }
    
    // MARK: - Type Properties
    static let reuseIdentifier = "PromptReplyTableCell"
    var collectionView: UICollectionView!
    var scoreImages: [UIImage] = [#imageLiteral(resourceName: "IC_Score_One_Unselected"), #imageLiteral(resourceName: "IC_Score_Two_Unselected"), #imageLiteral(resourceName: "IC_Score_Three_Unselected"), #imageLiteral(resourceName: "IC_Score_Four_Unselected"), #imageLiteral(resourceName: "IC_Score_Five_Unselected")]
    var scores: [Score] = Score.createScores()
    var replyId: String = ""
    weak var delegate: PromptTableCellDelegate?
    
    // MARK: - Properties
    fileprivate var containerView: UIView!
    fileprivate var userNameLabel: UILabel!
    fileprivate var replyBodyLabel: UILabel!
    fileprivate var labelsStackView: UIStackView!
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
        setupContainerView()
        setupCollectionViewProperties()
        setupUserNameLabelProperties()
        setupReplyBodyProperties()
        
        setupCollectionView()
        setupLabelsStackView()
    }
    
    fileprivate func setupCollectionViewProperties() {
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: PointsGridLayout())
        collectionView.backgroundColor = UIColor.orange
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ScoreCollectionCell.self, forCellWithReuseIdentifier: ScoreCollectionCell.reuseIdentifier)
    }
    
    func configure(with reply: PromptReply) {
        self.selectionStyle = .none
        userNameLabel.text = reply.userName
        replyBodyLabel.text = reply.body
        //collectionView.reloadData()
    }
    
    override func prepareForReuse() { }
    
}

extension PromptReplyTableCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scores.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScoreCollectionCell.reuseIdentifier, for: indexPath) as! ScoreCollectionCell
        cell.scoreImageView.image = scores[indexPath.item].getImage
        return cell
    }
    
}

extension PromptReplyTableCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let score = scores[indexPath.item].getScore
        delegate?.didSelectScore(score, replyId: replyId)
    }
    
}

//MARK: View Property Setup

extension PromptReplyTableCell {
    
    func setupUserNameLabelProperties() {
        userNameLabel = UILabel()
        userNameLabel.textColor = UIColor.black
        userNameLabel.numberOfLines = 1
        userNameLabel.font = FontBook.AvenirHeavy.of(size: 13)
    }
    
    func setupReplyBodyProperties() {
        replyBodyLabel = UILabel()
        replyBodyLabel.textColor = UIColor.black
        replyBodyLabel.numberOfLines = 0
        replyBodyLabel.font = FontBook.AvenirMedium.of(size: 12)
    }
    
}

//MARK: Constraints Setup

extension PromptReplyTableCell {
    
    func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    func setupCollectionView() {
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(containerView)
            make.height.equalTo(25)
        }
    }
    
    func setupLabelsStackView() {
        let views: [UILabel] = [userNameLabel, replyBodyLabel]
        labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 4.0
        labelsStackView.axis = .vertical
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.left.top.equalTo(containerView).offset(15)
            make.right.equalTo(containerView).offset(-15)
            make.bottom.equalTo(collectionView.snp.top).offset(-10)
        }
    }
    
}

class PointsGridLayout: UICollectionViewFlowLayout {
    
    let itemSpacing: CGFloat = 10.0
    
    override init() {
        super.init()
        self.minimumInteritemSpacing = itemSpacing
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func itemWidth() -> CGFloat {
        return 25
    }
    
    override var itemSize: CGSize {
        get {
            return CGSize(width: itemWidth(), height: itemWidth())
        }
        set {
            self.itemSize = CGSize(width: itemWidth(), height: itemWidth())
        }
    }
    
}
