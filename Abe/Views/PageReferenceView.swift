
import Foundation
import UIKit

final class PageIndicatorView: UIView {
    
    private var stackView: UIStackView!
    private var views = [UIView]()
    
    var currentPage: Int = 0 {
        didSet {
            self.adjustButtonColors(selected: currentPage)
        }
    }
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfItems: Int, widthHeight: CGFloat) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupStackView(numberOfItems: numberOfItems, widthHeight: widthHeight)
    }
    
}

extension PageIndicatorView {
    
    private func adjustButtonColors(selected tag: Int) {
        views.forEach {
            $0.backgroundColor =
                ($0.tag == tag) ? UIColor.black : Palette.faintGrey.color
        }
    }
    
    private func setupStackView(numberOfItems: Int, widthHeight: CGFloat) {
        guard numberOfItems > 0 else { return }
        for i in 0...numberOfItems - 1 {
            let view = UIView(frame: CGRect.zero)
            view.tag = i
            view.frame.size.width = widthHeight
            view.frame.size.height = widthHeight
            view.layer.cornerRadius = widthHeight/2
            views.append(view)
        }
        stackView = UIStackView(arrangedSubviews: views)
        stackView.spacing = 10.0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        //stackView.alignment = .fill
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
}
