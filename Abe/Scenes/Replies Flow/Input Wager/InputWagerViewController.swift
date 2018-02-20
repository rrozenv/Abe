
import Foundation
import RxSwift
import RxCocoa

final class InputWagerViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: InputWagerViewModel!
    
    private var backAndPagerView: BackButtonPageIndicatorView!
    private var selectedUserView: UserImageNameSublabelView!
    private var wagerTextField: UITextField!
    private var doneButton: UIButton!
    private var titleLabel: UILabel!
    private var titleSublabel: UILabel!
    private var labelsStackView: UIStackView!
    private var dividerView: UIView!
    private var skipButton: UIButton!
   
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        setupBackAndPagerView()
        setupSelectedUserView()
        setupDividerView()
        setupTitleLabel()
        setupDoneButton()
        setupWagerTextfield()
        setupSkipButton()
    }
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var inputAccessoryView: UIView? { get { return doneButton } }
    override var canBecomeFirstResponder: Bool { return true }
    deinit { print("Input Wager deinit") }
    
    func bindViewModel() {
        //MARK: - Inputs
        wagerTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.wagerTextInput)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.doneTappedInput)
            .disposed(by: disposeBag)
        
        backAndPagerView.backButton.rx.tap
            .bind(to: viewModel.inputs.backButtonTappedInput)
            .disposed(by: disposeBag)
        
        skipButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.skipButtonTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.wagerError
            .subscribe(onNext: { [weak self] in
                self?.handleError($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.guessedUser
            .drive(onNext: { [weak self] in
                self?.selectedUserView.populateInfoWith(name: $0.name,
                                                        subLabel: "YOUR GUESS")
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.currentPageIndicator
            .drive(onNext: { [weak self] in
                self?.backAndPagerView.pageIndicatorView.currentPage = $0
            })
            .disposed(by: disposeBag)
    }
    
    private func handleError(_ error: InputWagerError) {
        var header = ""
        var message = ""
        switch error {
        case .emptyWager:
            header = "Enter a wager amount!"
            message = "You can't simply wager nothing, come on now."
        case .notValidNumber:
            header = "Not Valid Number"
            message = "Enter a valid number you silly goose."
        case .notEnoughCoins(total: let total):
            header = "Not Enough Coins"
            message = "You are trying to wager more coins then you have. You currently have \(total) coins."
        case .greaterThanMaxAmount(max: let max):
            header = "Lower Wager Amount"
            message = "The max wager is \(max)."
        }
        let alert = UIAlertController(title: header, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupWagerTextfield() {
        wagerTextField = UITextField()
        wagerTextField.placeholder = "0"
        wagerTextField.textAlignment = .center
        wagerTextField.backgroundColor = UIColor.white
        wagerTextField.layer.cornerRadius = 4.0
        wagerTextField.layer.masksToBounds = true
        wagerTextField.font = FontBook.BariolBold.of(size: 38)
        wagerTextField.textColor = Palette.maroon.color
        wagerTextField.becomeFirstResponder()
        
        view.addSubview(wagerTextField)
        wagerTextField.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(labelsStackView.snp.bottom).offset(30)
            make.height.equalTo(view.snp.height).multipliedBy(0.11)
        }
    }
    
    private func setupDoneButton() {
        doneButton = UIButton()
        doneButton.backgroundColor = Palette.maroon.color
        doneButton.setTitle("Wager", for: .normal)
        doneButton.frame.size.height = 60
    }
    
    private func setupBackAndPagerView() {
        backAndPagerView = BackButtonPageIndicatorView()
        backAndPagerView.setupPageIndicatorView(numberOfPages: 3)
        
        view.addSubview(backAndPagerView)
        backAndPagerView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.top.equalTo(view.snp.top)
        }
    }
    
    private func setupSkipButton() {
        skipButton = UIButton()
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = FontBook.BariolBold.of(size: 14)
        skipButton.setTitleColor(Palette.maroon.color, for: .normal)
//        skipButton.contentEdgeInsets = UIEdgeInsets(top: 38, left: 26, bottom: 15, right: 15)
        
        view.addSubview(skipButton)
        skipButton.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right).offset(-30)
            make.centerY.equalTo(backAndPagerView.snp.centerY).offset(10)
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
    }
    
    private func setupSelectedUserView() {
        selectedUserView = UserImageNameSublabelView()
        
        view.addSubview(selectedUserView)
        selectedUserView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(26)
            make.top.equalTo(backAndPagerView.snp.bottom)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = FontBook.BariolBold.of(size: 18)
        let attributedString = NSMutableAttributedString(string: "Would you like to wager any of your crystals that you are correct?")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attributedString.length))
        titleLabel.attributedText = attributedString
        
        titleSublabel = UILabel()
        titleSublabel.numberOfLines = 0
        titleSublabel.font = FontBook.AvenirMedium.of(size: 14)
        titleSublabel.textColor = Palette.lightGrey.color
        titleSublabel.text = "Guessing correctly will DOUBLE your wager."
        
        let views: [UILabel] = [titleLabel, titleSublabel]
        labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 10.0
        labelsStackView.axis = .vertical
        
        view.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.top.equalTo(dividerView.snp.bottom).offset(24)
            make.left.equalTo(view).offset(26)
            make.right.equalTo(view).offset(-40)
        }
    }
    
    private func setupDividerView() {
        dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        view.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.top.equalTo(selectedUserView.snp.bottom).offset(17)
            make.left.right.equalTo(view)
            make.height.equalTo(2)
        }
    }
    
}
