
import Foundation
import RxSwift
import SnapKit

class RateReplyViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    let dataSource = RatingScoreDataSource()
    var viewModel: RateReplyViewModel!
   
    private var titleContainerView: UIView!
    private var backButton: UIButton!
    private var pageIndicatorView: PageIndicatorView!
    private var titleLabel: UILabel!
    private var nextButton: UIButton!
    private var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupBackButton()
        setupTitleLabel()
        setupTableView()
        setupNextButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialViewState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppearInput.onNext(())
    }
    
    override var inputAccessoryView: UIView? { get { return nextButton } }
    override var canBecomeFirstResponder: Bool { return true }
    deinit { print("rate reply deinit") }
    
    private func setInitialViewState() {
        nextButton.isHidden = true
        
        let attributedString = NSMutableAttributedString(string: "On a scale of 1-5, how much do you agree with this reply?")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 9
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attributedString.length))
        titleLabel.attributedText = attributedString
    }
    
    func bindViewModel() {
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .distinctUntilChanged()
            .map { [weak self] in self?.dataSource.rating($0) }.unwrap()
            .bind(to: viewModel.inputs.selectedScoreInput)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(to: viewModel.inputs.nextButtonTappedInput)
            .disposed(by: disposeBag)
        
//        let backButtonTappedObservable = Observable.of(
//            backAndPagerView.backButton.rx.tap.asObservable(),
//            cancelButton.rx.tap.asObservable()
//        )
//        .merge()
        
        backButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.backButtonTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.reply
            .drive(onNext: { [weak self] in
                let section = RatingScoreDataSource.Section.reply.rawValue
                self?.dataSource.loadUnlockedReply(viewModel: $0)
                self?.tableView.reloadSections([section], animationStyle: .none)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.ratingScores
            .drive(onNext: { [weak self] in
                self?.dataSource.loadRatings(ratings: $0)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.previousAndCurrentScore
            .subscribe(onNext: { [weak self] (inputs) in
                let section = RatingScoreDataSource.Section.ratings.rawValue
                let prevIndex = IndexPath(row: inputs.previous.value - 1, section: section)
                let currIndex = IndexPath(row: inputs.current.value - 1, section: section)
                self?.dataSource.toggleRating(at: currIndex)
                self?.tableView.reloadRows(at: [currIndex], with: .none)
               
                guard prevIndex.row != -1 else { return }
                self?.dataSource.toggleRating(at: prevIndex)
                self?.tableView.reloadRows(at: [prevIndex], with: .none)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.nextButtonIsEnabled
            .drive(onNext: { [weak self] in
                self?.nextButton.isHidden = $0 ? false : true
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.nextButtonTitle
            .drive(nextButton.rx.title())
            .disposed(by: disposeBag)
        
        viewModel.outputs.pageIndicator
            .drive(onNext: { [weak self] in
                guard let backButton = self?.backButton else { return }
                self?.setupPageIndicator(constrainedTo: backButton,
                                         total: $0.total,
                                         currentPage: $0.current)
            })
            .disposed(by: disposeBag)
    }
    
}

extension RateReplyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let section = RatingScoreDataSource.Section(rawValue: section) else { fatalError() }
        switch section {
        case .ratings:
            return nextButton
                .systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        case .reply:
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
}

extension RateReplyViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    fileprivate func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(RatingScoreTableCell.self, forCellReuseIdentifier: RatingScoreTableCell.defaultReusableId)
        tableView.register(RateReplyTableCell.self, forCellReuseIdentifier: RateReplyTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(titleContainerView.snp.bottom)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = Palette.brightYellow.color
        nextButton.setTitleColor(Palette.darkYellow.color, for: .normal)
        nextButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        nextButton.frame.size.height = 60
    }
    
    private func setupTitleLabel() {
        titleContainerView = UIView()
        titleContainerView.backgroundColor = UIColor.white
        
        let dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = FontBook.BariolBold.of(size: 18)
        
        titleContainerView.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(titleContainerView)
            make.height.equalTo(2)
        }
        
        titleContainerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainerView)
            make.left.equalTo(titleContainerView).offset(26)
            make.right.equalTo(titleContainerView).offset(-40)
            make.bottom.equalTo(dividerView.snp.top).offset(-15)
        }
        
        view.addSubview(titleContainerView)
        titleContainerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(backButton.snp.bottom)
        }
    }
    
    private func setupBackButton() {
        backButton = UIButton.backButton(image: #imageLiteral(resourceName: "IC_BackArrow_Black"))
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            if #available(iOS 11.0, *) {
                if UIDevice.iPhoneX {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-44)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-20)
                }
            } else {
                make.top.equalTo(view.snp.top)
            }
        }
    }
    
}

//final class BackButtonPageIndicatorView: UIView {
//
//    private let itemWidthHeight: CGFloat = 6
//    var stackWidthConstraint: Constraint!
//    var backButton: UIButton!
//    var pageIndicatorView: PageIndicatorView!
//    var updatePageTotal: Int = 0 {
//        didSet {
////            pageIndicatorView.updatePageTotal = updatePageTotal
////            updateStackWidth(numberOfPages: updatePageTotal)
////            layoutIfNeeded()
//        }
//    }
//
//    private func updateStackWidth(numberOfPages: Int) {
//        pageIndicatorView.snp.remakeConstraints { (make) in
//            make.left.equalTo(backButton.snp.right).offset(10)
//            make.right.equalTo(self)
//            make.centerY.equalTo(backButton.snp.centerY).offset(10)
//            make.height.equalTo(itemWidthHeight)
//            make.width.equalTo(widthForStackView(numberOfPages: numberOfPages, spacing: 10))
//        }
//    }
//
//    //MARK: Initalizer Setup
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    init() {
//        super.init(frame: .zero)
//        self.backgroundColor = UIColor.clear
//        setupBackButton()
//        //setupPageIndicatorView(numberOfPages: 2)
//    }
//
//    private func setupPageIndicatorView(numberOfPages: Int) {
//        pageIndicatorView = PageIndicatorView(numberOfItems: numberOfPages,
//                                              widthHeight: itemWidthHeight)
//
//        self.addSubview(pageIndicatorView)
//        pageIndicatorView.snp.makeConstraints { (make) in
//            make.left.equalTo(backButton.snp.right).offset(10)
//            make.right.equalTo(self)
//            make.centerY.equalTo(backButton.snp.centerY).offset(10)
//            make.height.equalTo(itemWidthHeight)
//            make.width.equalTo(widthForStackView(numberOfPages: numberOfPages, spacing: 10))
//        }
//    }
//
//    private func widthForStackView(numberOfPages: Int, spacing: CGFloat) -> CGFloat {
//        let spacing: CGFloat = 10.0
//        let spacingMultiplier = CGFloat(numberOfPages - 1)
//        let widthMultiplier = CGFloat(numberOfPages)
//        return (spacing * spacingMultiplier) + (itemWidthHeight * widthMultiplier)
//    }
//
//    private func setupBackButton() {
//        let image = #imageLiteral(resourceName: "IC_BackArrow_Black")
//        image.size.equalTo(CGSize(width: 9, height: 17))
//        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 9, height: 17))
//        backButton.setImage(image, for: .normal)
//        backButton.contentEdgeInsets = UIEdgeInsets(top: 38, left: 26, bottom: 15, right: 15)
//
//        self.addSubview(backButton)
//        backButton.snp.makeConstraints { (make) in
//            make.edges.equalTo(self)
//        }
//    }
//
//}


extension UIViewController {
    
    func setupPageIndicator(constrainedTo: UIView, total: Int, currentPage: Int) {
        let widthHeight: CGFloat = 6.0
        
        func widthForStackView(numberOfPages: Int) -> CGFloat {
            let spacing: CGFloat = 10.0
            let spacingMultiplier = CGFloat(numberOfPages - 1)
            let widthMultiplier = CGFloat(numberOfPages)
            return (spacing * spacingMultiplier) + (widthHeight * widthMultiplier)
        }
        
        let pageIndicatorView = PageIndicatorView(numberOfItems: total, widthHeight: 6.0)
        pageIndicatorView.currentPage = currentPage
        
        view.addSubview(pageIndicatorView)
        pageIndicatorView.snp.makeConstraints { (make) in
            make.left.equalTo(constrainedTo.snp.right).offset(10)
            make.centerY.equalTo(constrainedTo.snp.centerY).offset(10)
            make.height.equalTo(6.0)
            make.width.equalTo(widthForStackView(numberOfPages: total))
        }
    }
    
}




