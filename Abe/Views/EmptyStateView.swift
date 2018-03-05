
import Foundation
import UIKit

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

final class ContactsTableHeaderView: UIView {
    
    var containerView: UIView!
    var actionButton: UIButton!
    var titleLabel: UILabel!
    var searchBar: UISearchBar!
    var dividerView: UIView!
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupSearchBar()
        setupActionButton()
        setupTitleLabel()
        setupDividerView()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search Contacts"
        searchBar.barTintColor = Palette.faintGrey.color
        searchBar.backgroundColor = UIColor.white
        
        containerView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(containerView).offset(10)
            make.left.equalTo(containerView).offset(18)
            make.right.equalTo(containerView).offset(-18)
            make.height.equalTo(50)
        }
    }
    
    private func setupActionButton() {
        actionButton = UIButton()
        actionButton.backgroundColor = UIColor.clear
        actionButton.titleLabel?.font = FontBook.BariolBold.of(size: 14)
        actionButton.setTitleColor(Palette.red.color, for: .normal)
        actionButton.contentHorizontalAlignment = .right
        
        containerView.addSubview(actionButton)
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.right.equalTo(containerView).offset(-26)
            make.bottom.equalTo(containerView)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = FontBook.BariolBold.of(size: 14)
        titleLabel.textColor = UIColor.black
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(26)
            make.centerY.equalTo(actionButton.snp.centerY)
        }
    }
    
    private func setupDividerView() {
        dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        containerView.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.height.equalTo(3)
            make.left.equalTo(containerView).offset(26)
            make.right.equalTo(containerView).offset(-26)
            make.bottom.equalTo(containerView)
        }
    }
    
}

final class PublicVisibilitySectionHeaderView: UIView {
    
    var containerView: UIView!
    var titleLabel: UILabel!
    var imageNameSublabelView: UserImageNameSublabelView!
    var actionButton: UIButton!
    var cirleBorderView: UIView!
    var leftDividerView: UIView!
    var rightDividerView: UIView!
    var centerDividerLabel: UILabel!
    var iconImageView: UIImageView!
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        //setupTitleLabel()
        setupUserImageNameSublabelView()
        setupActionButton()
        setupCirleBorderView()
        setupIconImageView()
        setupLeftDividerView()
        setupRightDividerView()
        setupCenterDividerLabel()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.black
        titleLabel.font = FontBook.BariolBold.of(size: 16)
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(containerView)
            make.left.equalTo(containerView).offset(26)
            make.right.equalTo(containerView).offset(-26)
        }
    }
    
    private func setupUserImageNameSublabelView() {
        imageNameSublabelView = UserImageNameSublabelView()
        
        containerView.addSubview(imageNameSublabelView)
        imageNameSublabelView.snp.makeConstraints { (make) in
            make.top.equalTo(containerView)
            make.left.equalTo(containerView).offset(26)
            make.right.equalTo(containerView).offset(-26)
        }
    }
    
    private func setupActionButton() {
        actionButton = UIButton()
        actionButton.backgroundColor = UIColor.clear
        
        containerView.insertSubview(actionButton, aboveSubview: imageNameSublabelView)
        actionButton.snp.makeConstraints { (make) in
            make.edges.equalTo(imageNameSublabelView)
        }
    }
    
    private func setupCirleBorderView() {
        cirleBorderView = UIView()
        cirleBorderView.layer.borderWidth = 2.0
        cirleBorderView.layer.borderColor = Palette.lightGrey.color.cgColor
        cirleBorderView.layer.cornerRadius = 20/2
        cirleBorderView.layer.masksToBounds = true
        cirleBorderView.backgroundColor = UIColor.white
        
        imageNameSublabelView.addSubview(cirleBorderView)
        cirleBorderView.snp.makeConstraints { (make) in
            make.right.centerY.equalTo(imageNameSublabelView)
            make.height.width.equalTo(20)
        }
    }
    
    private func setupIconImageView() {
        iconImageView = UIImageView()
        iconImageView.isHidden = true
        
        containerView.insertSubview(iconImageView, aboveSubview: cirleBorderView)
        iconImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(cirleBorderView)
        }
    }
    
    private func setupLeftDividerView() {
        leftDividerView = UIView()
        leftDividerView.backgroundColor = Palette.faintGrey.color
        
        containerView.addSubview(leftDividerView)
        leftDividerView.snp.makeConstraints { (make) in
            make.top.equalTo(imageNameSublabelView.snp.bottom).offset(24)
            make.height.equalTo(3)
            make.width.equalTo(containerView).multipliedBy(0.42)
            make.left.equalTo(containerView)
            make.bottom.equalTo(containerView).offset(-5)
        }
    }
    
    private func setupRightDividerView() {
        rightDividerView = UIView()
        rightDividerView.backgroundColor = Palette.faintGrey.color
        
        containerView.addSubview(rightDividerView)
        rightDividerView.snp.makeConstraints { (make) in
            make.height.equalTo(3)
            make.width.equalTo(containerView).multipliedBy(0.42)
            make.right.equalTo(containerView)
            make.bottom.equalTo(containerView).offset(-5)
        }
    }
    
    private func setupCenterDividerLabel() {
        centerDividerLabel = UILabel()
        centerDividerLabel.font = FontBook.BariolBold.of(size: 18)
        centerDividerLabel.textColor = Palette.lightGrey.color
        
        containerView.addSubview(centerDividerLabel)
        centerDividerLabel.snp.makeConstraints { (make) in
            make.centerX.bottom.equalTo(containerView)
        }
    }
    
}
