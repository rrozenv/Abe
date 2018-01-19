
import Foundation
import UIKit

final class WebLinkActionButtonsView: UIView {
    
    var containerView: UIView!
    var searchButton: UIButton!
    var doneButton: UIButton!
    var displayDone: Bool = false {
        didSet {
            searchButton.isHidden = displayDone ? true : false
            doneButton.isHidden = displayDone ? false : true
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupContainerView()
        setupSearchButton()
        setupDoneButton()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupSearchButton() {
        searchButton = UIButton()
        searchButton.backgroundColor = UIColor.green
        searchButton.setTitle("Search", for: .normal)
        searchButton.isHidden = false
        
        containerView.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
    private func setupDoneButton() {
        doneButton = UIButton()
        doneButton.backgroundColor = UIColor.blue
        doneButton.setTitle("Done", for: .normal)
        doneButton.isHidden = true
        
        containerView.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
}
