
import Foundation
import UIKit

final class TabOptionsView: UIView {
    
    private var stackView: UIStackView!
    private var buttons = [UIButton]()
  
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
    
    func adjustButtonColors(selected tag: Int,
                            selectedBkgColor: UIColor,
                            selectedTitleColor: UIColor,
                            notSelectedBkgColor: UIColor,
                            notSelectedTitleColor: UIColor) {
        buttons.forEach {
            $0.backgroundColor =
                ($0.tag == tag) ? selectedBkgColor : notSelectedBkgColor
            $0.setTitleColor(($0.tag == tag) ? selectedTitleColor : notSelectedTitleColor, for: .normal)
        }
    }
    
    private func setupStackView(numberOfItems: Int) {
        guard numberOfItems > 0 else { return }
        for i in 0...numberOfItems - 1 {
            let button = UIButton()
            button.tag = i
            button.titleLabel?.font = FontBook.BariolBold.of(size: 14)
            buttons.append(button)
        }
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
