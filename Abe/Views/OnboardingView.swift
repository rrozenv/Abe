
import Foundation
import UIKit

final class OnboardingView: UIView {
    
    var headerLabel: UILabel!
    var bodyLabel: UILabel!
    
    private var buttonStackView: UIStackView!
    private var dividerView: UIView!
    private var labelsStackView: UIStackView!
    private var buttons = [UIButton]()
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfButtons: Int) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        if numberOfButtons > 0 { setupButtonStackView(numberOfItems: numberOfButtons) }
        setupDividerView(numberOfButtons: numberOfButtons)
        setupLabelsStackView()
    }
    
}

extension OnboardingView {
    
    func setTitleForButton(title: String, at index: Int) {
        guard index < buttons.count else { return }
        buttons[index].setTitle(title, for: .normal)
    }
    
    func button(at index: Int) -> UIButton {
        guard index < buttons.count else { fatalError() }
        return buttons[index]
    }
    
    func styleDividerView(color: UIColor, size: CGSize?) {
        dividerView.backgroundColor = color
        guard let size = size else { return }
        dividerView.snp.updateConstraints { (make) in
            make.height.equalTo(size.height)
            make.height.equalTo(size.width)
        }
    }
    
    func resizeButton(size: CGSize) {
        button(at: 0).snp.updateConstraints { (make) in
            make.height.equalTo(size.height)
            make.height.equalTo(size.width)
        }
    }
    
}

extension OnboardingView {
    
    private func setupButtonStackView(numberOfItems: Int) {
        guard numberOfItems > 0 else { return }
        for i in 0...numberOfItems - 1 {
            let button = UIButton()
            button.tag = i
            button.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
            button.layer.cornerRadius = 5.0
            button.dropShadow()
            buttons.append(button)
        }
        let spacing: CGFloat = 18
        buttonStackView = UIStackView(arrangedSubviews: buttons)
        buttonStackView.spacing = spacing
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fillEqually
        
        let height = numberOfItems > 1 ? (50.0 * CGFloat(numberOfItems)) + spacing : (50.0 * CGFloat(numberOfItems))
        self.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { (make) in
            make.bottom.left.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(height)
        }
    }
    
    private func setupDividerView(numberOfButtons: Int) {
        dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        self.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.width.equalTo(self)
            make.left.equalTo(self)
            if numberOfButtons > 0 {
                make.bottom.equalTo(buttonStackView.snp.top).offset(-22)
            } else {
                make.bottom.equalTo(self)
            }
        }
    }
    
    private func setupLabelsStackView() {
        headerLabel = UILabel()
        headerLabel.textColor = UIColor.black
        headerLabel.numberOfLines = 1
        headerLabel.font = FontBook.AvenirBlack.of(size: 14)
        
        bodyLabel = UILabel()
        bodyLabel.textColor = Palette.lightGrey.color
        bodyLabel.numberOfLines = 0
        bodyLabel.font = FontBook.AvenirMedium.of(size: 14)
        
        let views: [UIView] = [headerLabel, bodyLabel]
        labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 4.0
        labelsStackView.axis = .vertical
        
        self.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.bottom.equalTo(dividerView.snp.top).offset(-14)
            make.left.right.top.equalTo(self)
        }
    }
    
}

extension UILabel {
    
    func style(font: FontBook, size: CGFloat, color: UIColor) {
        self.font = font.of(size: size)
        self.textColor = color
    }
    
}

extension UIButton {
    
    func style(title: String?, font: FontBook?, fontSize: CGFloat?, backColor: UIColor?, titleColor: UIColor) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font?.of(size: fontSize ?? 12)
        self.backgroundColor = backColor
        self.setTitleColor(titleColor, for: .normal)
    }
    
}


extension UITextField {
    
    func style(placeHolder: String?, font: FontBook?, fontSize: CGFloat?, backColor: UIColor?, titleColor: UIColor) {
        self.placeholder = placeHolder
        self.backgroundColor = backColor
        self.font = font?.of(size: fontSize ?? 12)
        self.textColor = titleColor
    }
    
}

class PaddedTextField: UITextField {
    
    var padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    init(padding: CGFloat) {
        super.init(frame: .zero)
        self.padding = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
}


