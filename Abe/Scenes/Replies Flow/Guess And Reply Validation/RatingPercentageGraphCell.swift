
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
        barGraphView.constructWithDataAs(percentages: value.orderedPercetages)
    }
    
}

extension RatingPercentageGraphCell {
    
    //MARK: View Setup
    private func setupBarGraphView() {
        barGraphView = BarGraphView(numberOfColumns: 5)
        
        contentView.addSubview(barGraphView)
        barGraphView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
            make.height.equalTo(200)
        }
    }

}

final class BarGraphView: UIView {
    
    var containerView: UIView!
    var stackView: UIStackView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfColumns: Int) {
        super.init(frame: .zero)
        //setupContainerView()
        setupBarGraphStackView(numberOfColumns: numberOfColumns)
    }
    
//    private func setupContainerView() {
//        containerView = UIView()
//        containerView.backgroundColor = UIColor.white
//
//        self.addSubview(containerView)
//        containerView.snp.makeConstraints { (make) in
//            make.edges.equalTo(self)
//        }
//    }
    
    private func setupBarGraphStackView(numberOfColumns: Int) {
        var views = [UIView]()
        for _ in 0...numberOfColumns - 1 {
            let view = UIView(frame: CGRect.zero)
            views.append(view)
        }
        stackView = UIStackView(arrangedSubviews: views)
        stackView.spacing = 10.0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .bottom
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func constructWithDataAs(percentages: [Double]) {
        self.removeAllGraphElements()
        for percentage in percentages {
            self.newBarElementWith(percentage: percentage)
        }
    }
    
    func newBarElementWith(percentage: Double) {
        let height = heightPixelsDependOfPercentage(percentage: percentage)
        let view = UIView()
        view.backgroundColor = UIColor.green
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
        let maxHeight: CGFloat = 90.0
        return (CGFloat(percentage) * maxHeight) / 100
    }
    
}
