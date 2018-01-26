
import Foundation
import RxSwift

class RateReplyViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    let dataSource = RatingScoreDataSource()
    var viewModel: RateReplyViewModel!
   
    private var titleContainerView: UIView!
    private var pageIndicatorView: PageIndicatorView!
    private var titleLabel: UILabel!
    private var nextButton: UIButton!
    private var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
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
                self?.setupPageIndicatorView(numberOfPages: 3)
                self?.pageIndicatorView.currentPage = $0
            })
            .disposed(by: disposeBag)
    }
    
}

extension RateReplyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
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
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(titleContainerView.snp.bottom)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = UIColor.blue
        nextButton.alpha = 0.5
        nextButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(60)
        }
    }
    
    private func setupPageIndicatorView(numberOfPages: Int) {
        let spacing: CGFloat = 10.0
        let itemWidthHeight: CGFloat = 6
        let spacingMultiplier = CGFloat(numberOfPages - 1)
        let widthMultiplier = CGFloat(numberOfPages)
        let stackWidth = (spacing * spacingMultiplier) + (itemWidthHeight * widthMultiplier)
        pageIndicatorView = PageIndicatorView(numberOfItems: numberOfPages, widthHeight: itemWidthHeight)
        
        view.addSubview(pageIndicatorView)
        pageIndicatorView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(30)
            make.top.equalTo(view).offset(50)
            make.height.equalTo(itemWidthHeight)
            make.width.equalTo(stackWidth)
        }
    }
    
    private func setupTitleLabel() {
        titleContainerView = UIView()
        titleContainerView.backgroundColor = UIColor.white
        
        let dividerView = UIView()
        dividerView.backgroundColor = UIColor.gray
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = FontBook.AvenirMedium.of(size: 17)
        titleLabel.text = "On a scale of 1-5, how much do you agree with this reply?"
        
        titleContainerView.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(titleContainerView)
            make.height.equalTo(2)
        }
        
        titleContainerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainerView)
            make.left.equalTo(titleContainerView).offset(36)
            make.right.equalTo(titleContainerView).offset(-36)
            make.bottom.equalTo(dividerView.snp.top).offset(-15)
        }
        
        view.addSubview(titleContainerView)
        titleContainerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view.snp.top).offset(100)
        }
        
    }
    
}


