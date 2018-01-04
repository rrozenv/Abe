
import Foundation
import RxSwift
import RxDataSources
import PhoneNumberKit

class PhoneEntryViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: PhoneEntryViewModel!
    
    fileprivate var phoneTextField: UITextField!
    fileprivate var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupPhoneTextField()
        setupDoneButton()
        bindViewModel()
    }
    
    deinit {
        print("Create prompt deint")
    }
    
    func bindViewModel() {
        //MARK: - Input
        let input =
            PhoneEntryViewModel
                .Input(phoneNumber: phoneTextField.rx.text.orEmpty.asDriver(),
                       doneTapped: doneButton.rx.tap.asDriver())
        
        //MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.entryIsValid
            .drive(onNext: { [weak self] in
                self?.doneButton.isEnabled = $0 ? true : false
                self?.doneButton.tintColor = $0 ? UIColor.red : UIColor.gray
            })
            .disposed(by: disposeBag)
        
        output.numberIsVerified
            .drive(onNext: { _ in print("Number is verified") })
            .disposed(by: disposeBag)
        
        output.errors
            .drive(onNext: { [unowned self] error in self.showError(error) })
            .disposed(by: disposeBag)
    }
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension PhoneEntryViewController {
    
    fileprivate func setupDoneButton() {
        doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func setupPhoneTextField() {
        phoneTextField = UITextField()
        //titleTextView.font = FontBook.AvenirHeavy.of(size: 14)
        phoneTextField.backgroundColor = UIColor.yellow
        phoneTextField.placeholder = "Phone Number"
        
        view.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
        }
    }
    
}

