
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
    private var dividerView: UIView!
   
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        setupBackAndPagerView(numberOfPages: 3)
        setupSelectedUserView()
        setupDividerView()
        setupTitleLabel()
        setupDoneButton()
        setupWagerTextfield()
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
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .bind(to: viewModel.inputs.wagerTextInput)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.doneTappedInput)
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
    }
    
    private func handleError(_ error: InputWagerError) {
        var header = ""
        var message = ""
        switch error {
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
        wagerTextField.backgroundColor = UIColor.white
        wagerTextField.layer.cornerRadius = 4.0
        wagerTextField.layer.masksToBounds = true
        wagerTextField.font = FontBook.BariolBold.of(size: 26)
        wagerTextField.textColor = Palette.maroon.color
        wagerTextField.becomeFirstResponder()
        
        view.addSubview(wagerTextField)
        wagerTextField.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.center.equalTo(view.snp.center)
            make.height.equalTo(view.snp.height).multipliedBy(0.11)
        }
    }
    
    private func setupDoneButton() {
        doneButton = UIButton()
        doneButton.backgroundColor = UIColor.green
        doneButton.setTitle("Next", for: .normal)
        doneButton.frame.size.height = 60
    }
    
    private func setupBackAndPagerView(numberOfPages: Int) {
        backAndPagerView = BackButtonPageIndicatorView(numberOfPages: numberOfPages)
        
        view.addSubview(backAndPagerView)
        backAndPagerView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.top.equalTo(view.snp.top)
        }
    }
    
    private func setupSelectedUserView() {
        selectedUserView = UserImageNameSublabelView()
        
        view.addSubview(selectedUserView)
        selectedUserView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(30)
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
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dividerView.snp.bottom).offset(10)
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-40)
        }
    }
    
    private func setupDividerView() {
        dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        view.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.top.equalTo(selectedUserView.snp.bottom).offset(10)
            make.left.right.equalTo(view)
            make.height.equalTo(2)
        }
    }
    
}
