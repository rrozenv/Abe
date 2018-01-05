
import Foundation
import UIKit
import SnapKit

struct Screen {
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
}

struct Device {
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
}

final class TabBarView: UIView {
    
    //MARK: View Properties
    private let height1X: CGFloat = 50.0
    var containerView: UIView!
    var leftButton: UIButton!
    var centerButton: UIButton!
    var rightButton: UIButton!
    var selectedVisibility: Visibility = .all {
        didSet {
            self.adjustButtonColors(selected: getButtonTag(for: selectedVisibility))
        }
    }
    
    private var buttonArray: [UIButton] {
        return [leftButton, centerButton, rightButton]
    }
    
    var height: CGFloat {
        return Screen.height * (height1X / Screen.height)
    }
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(leftTitle: String,
         centerTitle: String,
         rightTitle: String) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        self.dropShadow()
        setupBackgroundView()
        setupLeftButton(with: leftTitle)
        setupCenterButton(with: centerTitle)
        setupRightButton(with: rightTitle)
        setupButtonStackView()
    }
    
}

extension TabBarView {
    
    fileprivate func adjustButtonColors(selected tag: Int) {
        buttonArray.forEach {
            $0.backgroundColor =
                ($0.tag == tag) ? UIColor.black : UIColor.gray
        }
    }
    
    fileprivate func getButtonTag(for visibility: Visibility) -> Int {
        switch visibility {
        case .all: return 1
        case .contacts: return 2
        case .userReply: return 3
        default: return 0
        }
    }
    
}

extension TabBarView {
    
    fileprivate func setupBackgroundView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.snp.makeConstraints { (make) in
            make.edges.edges.equalTo(self)
        }
    }
    
    fileprivate func setupButtonStackView() {
        let buttons: [UIButton] = [leftButton, centerButton, rightButton]
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
    fileprivate func setupLeftButton(with title: String) {
        leftButton = UIButton()
        leftButton.tag = 1
        leftButton.setTitle(title, for: .normal)
        leftButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        leftButton.backgroundColor = UIColor.black
    }
    
    fileprivate func setupCenterButton(with title: String) {
        centerButton = UIButton()
        centerButton.tag = 2
        centerButton.setTitle(title, for: .normal)
        centerButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        centerButton.backgroundColor = UIColor.black
    }
    
    fileprivate func setupRightButton(with title: String) {
        rightButton = UIButton()
        rightButton.tag = 3
        rightButton.setTitle(title, for: .normal)
        rightButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        rightButton.backgroundColor = UIColor.black
    }
    
}

final class RepliesEmptyView: UIView {
    
    var containerView: UIView!
    var titleLabel: UILabel!
    var selectedVisibility: Visibility = .all {
        didSet {
            self.setTitleText(for: selectedVisibility)
        }
    }

    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupTitleLabel()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.red
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.snp.makeConstraints { (make) in
            make.edges.edges.equalTo(self)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(containerView.snp.center)
        }
    }
    
    private func setTitleText(for visibility: Visibility) {
        switch visibility {
        case .all: titleLabel.text = "No Trending Replies"
        case .contacts: titleLabel.text = "No Replies For Contacts"
        case .userReply: titleLabel.text = "You did not reply"
        default: break
        }
    }

}

