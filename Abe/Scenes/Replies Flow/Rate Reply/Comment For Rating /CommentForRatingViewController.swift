
import Foundation
import RxSwift
import RxCocoa

class CommentForRatingViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: CommentForRatingViewModel!
    
    private var titleContainerView: UIView!
    private var titleLabel: UILabel!
    private var nextButton: UIButton!
    private var backButton: UIButton!
    private var pageIndicatorView: PageIndicatorView!
    private var bodyTextView: UITextView!
    private var optionsBarView: TabOptionsView!
    private var replyView: ReplyHeaderView!
    private var scrollView: UIScrollView!
    private var bodyPlaceholderLabel: UILabel!
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        setupBackButton()
        setupTitleLabel()
        setupScrollView()
        setupContentStackView()
        setupNextButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialViewState()
        bodyTextView.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppearInput.onNext(())
    }
    
    override var inputAccessoryView: UIView? { get { return nextButton } }
    override var canBecomeFirstResponder: Bool { return true }
    deinit { print("Create prompt VC deint") }
    
    private func setInitialViewState() {
        nextButton.isHidden = true
        
        let attributedString = NSMutableAttributedString(string: "Explain the reasoning for your rating...")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 9
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attributedString.length))
        titleLabel.attributedText = attributedString
    }
    
    func bindViewModel() {
        //MARK: - Input
        bodyTextView.rx.text.orEmpty
            .do(onNext: { [unowned self] in self.bodyPlaceholderLabel.isHidden = $0 == "" ? false : true })
            .bind(to: viewModel.inputs.bodyTextInput)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind(to: viewModel.inputs.backButtonTappedInput)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(to: viewModel.inputs.nextButtonTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.nextButtonIsEnabled
            .drive(onNext: { [weak self] in
                self?.nextButton.isHidden = $0 ? false : true
                self?.nextButton.backgroundColor = $0 ? Palette.brightYellow.color : Palette.lightGrey.color
                self?.nextButton.setTitleColor($0 ? Palette.darkYellow.color : UIColor.gray, for: .normal)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.pageIndicator
            .drive(onNext: { [weak self] in
                guard let backButton = self?.backButton else { return }
                self?.setupPageIndicator(constrainedTo: backButton,
                                         total: $0.total,
                                         currentPage: $0.current)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.reply
            .drive(onNext: { [weak self] in
                self?.replyView.populateInfoWith(reply: $0)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.nextButtonTitle
            .drive(onNext: { [weak self] in
                self?.nextButton.setTitle($0, for: .normal)
            })
            .disposed(by: disposeBag)
        
        UIDevice.keyboardHeight()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.scrollView.contentInset = UIEdgeInsetsMake(0, 0, $0, 0)
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension CommentForRatingViewController {
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = Palette.brightYellow.color
        nextButton.setTitleColor(Palette.darkYellow.color, for: .normal)
        nextButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        nextButton.frame.size.height = 60
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
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.bottom.right.equalTo(view).offset(-20)
            make.left.equalTo(view).offset(20)
            make.top.equalTo(titleContainerView.snp.bottom).offset(20)
        }
    }
    
    fileprivate func setupContentStackView() {
        replyView = ReplyHeaderView()
        
        bodyTextView = UITextView()
        bodyTextView.font = FontBook.AvenirMedium.of(size: 14)
        bodyTextView.isEditable = true
        bodyTextView.isScrollEnabled = true
        bodyTextView.backgroundColor = UIColor.white
        
        bodyPlaceholderLabel = UILabel()
        bodyPlaceholderLabel.text = "Enter description..."
        bodyPlaceholderLabel.font = FontBook.AvenirMedium.of(size: 14)
        bodyPlaceholderLabel.textColor = Palette.lightGrey.color
        
        bodyTextView.addSubview(bodyPlaceholderLabel)
        bodyPlaceholderLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(bodyTextView).offset(7)
        }
        
        let views: [UIView] = [bodyTextView, replyView]
        let contentStackView = UIStackView(arrangedSubviews: views)
        contentStackView.spacing = 10.0
        contentStackView.axis = .vertical
        
        //let imageHeight = selectedImageView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        scrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.height.equalTo(view).multipliedBy(0.78)
            make.width.equalTo(scrollView.snp.width)
        }
    }
    
}
