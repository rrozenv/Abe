
import Foundation
import RxSwift

class RateReplyViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    let dataSource = RatingScoreDataSource()
    var viewModel: RateReplyViewModel!
   
    private var titleContainerView: UIView!
    private var backAndPagerView: BackButtonPageIndicatorView!
    private var pageIndicatorView: PageIndicatorView!
    private var titleLabel: UILabel!
    private var nextButton: UIButton!
    private var tableView: UITableView!
    //private var backButton: UIButton!
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupBackAndPagerView(numberOfPages: 0)
        //setupBackButton()
        setupTitleLabel()
        setupTableView()
        setupNextButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppearInput.onNext(())
    }
    
    deinit { print("rate reply deinit") }
    
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
        
        backAndPagerView.backButton.rx.tap
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
                self?.nextButton.isEnabled = $0
                self?.nextButton.alpha = 1.0
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.nextButtonTitle
            .drive(nextButton.rx.title())
            .disposed(by: disposeBag)
        
        viewModel.outputs.currentPageIndicator
            .drive(onNext: { [weak self] in
                guard $0 != -1 else { return }
                self?.backAndPagerView.updatePageNumber = 3
                self?.pageIndicatorView.currentPage = $0
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
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(titleContainerView.snp.bottom)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = Palette.mustard.color
        nextButton.alpha = 0.5
        nextButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(60)
        }
    }
    
//    private func setupPageIndicatorView(numberOfPages: Int) {
//        let spacing: CGFloat = 10.0
//        let itemWidthHeight: CGFloat = 6
//        let spacingMultiplier = CGFloat(numberOfPages - 1)
//        let widthMultiplier = CGFloat(numberOfPages)
//        let stackWidth = (spacing * spacingMultiplier) + (itemWidthHeight * widthMultiplier)
//        pageIndicatorView = PageIndicatorView(numberOfItems: numberOfPages, widthHeight: itemWidthHeight)
//
//        view.addSubview(pageIndicatorView)
//        pageIndicatorView.snp.makeConstraints { (make) in
//            make.left.equalTo(backButton.snp.right).offset(20)
//            make.centerY.equalTo(backButton.snp.centerY)
//            make.height.equalTo(itemWidthHeight)
//            make.width.equalTo(stackWidth)
//        }
//    }
    
    private func setupTitleLabel() {
        titleContainerView = UIView()
        titleContainerView.backgroundColor = UIColor.white
        
        let dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = FontBook.BariolBold.of(size: 18)
        let attributedString = NSMutableAttributedString(string: "On a scale of 1-5, how much do you agree with this reply?")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 9
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attributedString.length))
        titleLabel.attributedText = attributedString
        
        titleContainerView.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(titleContainerView)
            make.height.equalTo(2)
        }
        
        titleContainerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainerView)
            make.left.equalTo(titleContainerView).offset(30)
            make.right.equalTo(titleContainerView).offset(-40)
            make.bottom.equalTo(dividerView.snp.top).offset(-15)
        }
        
        view.addSubview(titleContainerView)
        titleContainerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(backAndPagerView.snp.bottom)
        }
        
    }
    
//    private func setupBackButton() {
//        let image = #imageLiteral(resourceName: "IC_BackArrow_Black")
//        image.size.equalTo(CGSize(width: 9, height: 17))
//        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 9, height: 17))
//        backButton.setImage(image, for: .normal)
//        backButton.contentEdgeInsets = UIEdgeInsets(top: 38, left: 26, bottom: 15, right: 15)
//
//        view.addSubview(backButton)
//        backButton.snp.makeConstraints { (make) in
//            make.left.equalTo(view.snp.left)
//            make.top.equalTo(view.snp.top)
//        }
//    }
    
    private func setupBackAndPagerView(numberOfPages: Int) {
        backAndPagerView = BackButtonPageIndicatorView(numberOfPages: numberOfPages)
        view.addSubview(backAndPagerView)
        backAndPagerView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.top.equalTo(view.snp.top)
        }
    }
    
}

final class BackButtonPageIndicatorView: UIView {
    
    var backButton: UIButton!
    private var pageIndicatorView: PageIndicatorView!
    private let itemWidthHeight: CGFloat = 6
    var updatePageNumber: Int = 0 {
        didSet {
            pageIndicatorView = PageIndicatorView(numberOfItems: updatePageNumber, widthHeight: itemWidthHeight)
        }
    }
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfPages: Int) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupBackButton()
        setupPageIndicatorView(numberOfPages: numberOfPages)
    }
    
    private func setupBackButton() {
        let image = #imageLiteral(resourceName: "IC_BackArrow_Black")
        image.size.equalTo(CGSize(width: 9, height: 17))
        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 9, height: 17))
        backButton.setImage(image, for: .normal)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 38, left: 26, bottom: 15, right: 15)
        
        self.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self)
        }
    }
    
    private func setupPageIndicatorView(numberOfPages: Int) {
        let spacing: CGFloat = 10.0
        let spacingMultiplier = CGFloat(numberOfPages - 1)
        let widthMultiplier = CGFloat(numberOfPages)
        let stackWidth = (spacing * spacingMultiplier) + (itemWidthHeight * widthMultiplier)
        pageIndicatorView = PageIndicatorView(numberOfItems: numberOfPages, widthHeight: itemWidthHeight)
        
        self.addSubview(pageIndicatorView)
        pageIndicatorView.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.snp.right).offset(20)
            make.right.equalTo(self)
            make.centerY.equalTo(backButton.snp.centerY)
            make.height.equalTo(itemWidthHeight)
            make.width.equalTo(stackWidth)
        }
    }
    
}




