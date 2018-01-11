
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
    var selectedFilter: FilterOption = .locked {
        didSet {
            self.adjustButtonColors(selected: getButtonTag(for: selectedFilter))
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
    
    fileprivate func getButtonTag(for visibility: FilterOption) -> Int {
        switch visibility {
        case .locked: return 1
        case .unlocked: return 2
        case .myReply: return 3
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
            make.height.equalTo(50)
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



