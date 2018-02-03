
import Foundation
import UIKit

final class TabOptionsView: UIView {
    
    private var stackView: UIStackView!
    private var buttons = [UIButton]()
    var currentTab: Int = 0 {
        didSet {
            self.adjustButtonColors(selected: currentTab)
        }
    }
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfItems: Int) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupStackView(numberOfItems: numberOfItems)
    }
    
}

extension TabOptionsView {
    
    func setTitleForButton(title: String, at index: Int) {
        guard index < buttons.count else { return }
        buttons[index].setTitle(title, for: .normal)
    }
    
    func button(at index: Int) -> UIButton {
        guard index < buttons.count else { fatalError() }
        return buttons[index]
    }
    
    private func adjustButtonColors(selected tag: Int) {
        buttons.forEach {
            $0.backgroundColor =
                ($0.tag == tag) ? UIColor.black : Palette.lightGrey.color
        }
    }
    
    private func setupStackView(numberOfItems: Int) {
        guard numberOfItems > 0 else { return }
        for i in 0...numberOfItems - 1 {
            let button = UIButton()
            button.tag = i
            buttons.append(button)
        }
        currentTab = 0
        stackView = UIStackView(arrangedSubviews: buttons)
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
}
