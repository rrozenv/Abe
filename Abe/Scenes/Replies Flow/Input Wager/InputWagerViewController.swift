
import Foundation
import RxSwift
import RxCocoa

final class InputWagerViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: InputWagerViewModel!
    private var wagerTextField: UITextField!
    private var doneButton: UIButton!
   
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        setupDoneButton()
        setupSearchTextfield()
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
    
    private func setupSearchTextfield() {
        wagerTextField = UITextField()
        wagerTextField.placeholder = "Search Images..."
        wagerTextField.backgroundColor = UIColor.red
        wagerTextField.layer.cornerRadius = 4.0
        wagerTextField.layer.masksToBounds = true
        wagerTextField.font = FontBook.AvenirMedium.of(size: 14)
        wagerTextField.textColor = UIColor.black
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
    
}
