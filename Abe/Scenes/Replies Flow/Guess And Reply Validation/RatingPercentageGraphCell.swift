
import Foundation
import UIKit

final class RatingPercentageGraphCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = PercentageGraphViewModel
    static var defaultReusableId: String = "RatingPercentageGraphCell"
    private var barGraphView: BarGraphView!
    
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
        setupBarGraphView()
    }
    
    // MARK: - Configuration
    func configureWith(value: PercentageGraphViewModel) {
        barGraphView.titleLabel.text = "\(value.totalVotes) votes"
        barGraphView.constructWithDataAs(percentages: value.orderedPercetages, userScore: value.userScore.score)
    }
    
}

extension RatingPercentageGraphCell {
    
    //MARK: View Setup
    private func setupBarGraphView() {
        let images = [#imageLiteral(resourceName: "IC_AngryEmoji"), #imageLiteral(resourceName: "IC_ToungeEmoji"), #imageLiteral(resourceName: "IC_SmirkEmoji"), #imageLiteral(resourceName: "IC_HappyEmoji"), #imageLiteral(resourceName: "IC_LoveEmoji")]
        barGraphView = BarGraphView(numberOfColumns: images.count, xAxisImages: images)
        barGraphView.dropShadow()
        
        contentView.addSubview(barGraphView)
        barGraphView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(20)
            //make.height.equalTo(200)
        }
    }

}

final class BarGraphView: UIView {
    
    var containerView: UIView!
    var stackView: UIStackView!
    var imageStackView: UIStackView!
    var titleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfColumns: Int, xAxisImages: [UIImage]) {
        super.init(frame: .zero)
        setupContainerView()
        setupTitleLabel()
        setupImageStackView(images: xAxisImages)
        setupBarGraphStackView(numberOfColumns: numberOfColumns)
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = Palette.brightYellow.color

        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = FontBook.BariolBold.of(size: 14)
        titleLabel.textColor = Palette.darkYellow.color
        titleLabel.numberOfLines = 1
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(containerView).offset(20)
        }
    }
    
    private func setupImageStackView(images: [UIImage]) {
        var imageViews: [ImageWithBackgroundView] = []
        images.forEach {
            let imageView = ImageWithBackgroundView(image: $0)
            imageView.containerView.backgroundColor = Palette.red.color
            imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            imageViews.append(imageView)
        }
        imageStackView = UIStackView(arrangedSubviews: imageViews)
        imageStackView.spacing = 10.0
        imageStackView.axis = .horizontal
        imageStackView.distribution = .fillEqually
        imageStackView.alignment = .center
        
        containerView.addSubview(imageStackView)
        imageStackView.snp.makeConstraints { (make) in
            make.bottom.right.left.equalTo(containerView)
            make.height.equalTo(40)
        }
    }
    
    private func setupBarGraphStackView(numberOfColumns: Int) {
        var views = [BarViewWithLabel]()
        for _ in 0...numberOfColumns - 1 {
            let view = BarViewWithLabel()
            views.append(view)
        }
        stackView = UIStackView(arrangedSubviews: views)
        stackView.spacing = 10.0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .bottom
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.right.equalTo(containerView)
            make.bottom.equalTo(imageStackView.snp.top)
            make.height.equalTo(150)
        }
    }
    
    func constructWithDataAs(percentages: [Double], userScore: Int) {
        self.removeAllGraphElements()
        for i in percentages.enumerated() {
            let color = i.offset == userScore - 1 ? Palette.red.color : Palette.darkYellow.color
            self.newBarElementWith(percentage: i.element, backgroundColor: color)
        }
    }
    
    func newBarElementWith(percentage: Double, backgroundColor: UIColor) {
        let height = heightPixelsDependOfPercentage(percentage: percentage)
        let view = BarViewWithLabel()
        view.barView.backgroundColor = backgroundColor
        view.label.text = "\(Int(percentage)) %"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        stackView.addArrangedSubview(view)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func removeAllGraphElements () {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
    
    private func heightPixelsDependOfPercentage(percentage: Double) -> CGFloat {
        let maxHeight: CGFloat = 140.0
        return (CGFloat(percentage) * maxHeight) / 100
    }
    
}

final class ImageWithBackgroundView: UIView {
    
    var containerView: UIView!
    var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(image: UIImage) {
        super.init(frame: .zero)
        setupContainerView()
        setupImageViewWith(image: image)
    }
    
    private func setupContainerView() {
        containerView = UIView()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupImageViewWith(image: UIImage) {
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.center.equalTo(containerView)
        }
    }
    
}

final class BarViewWithLabel: UIView {
    
    var label: UILabel!
    var barView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupLabel()
        setupBarView()
    }
    
    private func setupLabel() {
        label = UILabel()
        label.textColor = Palette.darkYellow.color
        label.numberOfLines = 1
        label.font = FontBook.BariolBold.of(size: 14)
        label.textAlignment = .center
        
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
        }
    }
    
    private func setupBarView() {
        barView = UIView()
        
        self.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(label.snp.bottom).offset(5)
        }
    }
    
}
