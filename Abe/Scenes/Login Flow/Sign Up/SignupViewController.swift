
import Foundation
import UIKit
import RxSwift
import RxCocoa
import Action
import SnapKit

class SignUpViewController: UIViewController {
    
    var viewModel: SignupViewModel!
    
    var emailTextField = UITextField()
    var usernameTextField = UITextField()
    var passwordTextField = UITextField()
    var registerButton = UIButton()
    var loginButton = UIButton()
    var alertAction = UIAlertAction.Action("OK", style: .default)
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupFields()
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        
        //MARK: - Input
        let input = SignupViewModel.Input(userName: usernameTextField.rx.text.orEmpty.asDriver(),
                              email: emailTextField.rx.text.orEmpty.asDriver(),
                              password: passwordTextField.rx.text.orEmpty.asDriver(),
                              signUpTrigger: registerButton.rx.tap.asObservable(),
                              loginTrigger: loginButton.rx.tap.asObservable())
       
        
        //MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.userInputIsValid
            .drive(onNext: { [weak self] (isValid) in
                self?.registerButton.isEnabled = isValid ? true : false
                self?.registerButton.backgroundColor = isValid ? UIColor.red : UIColor.gray
            })
            .disposed(by: disposeBag)
        
        output.exisitingUser
            .drive()
            .disposed(by: disposeBag)
        
        output.newUser
            .drive()
            .disposed(by: disposeBag)
        
        output.errors
            .drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        
        output.loading
            .drive(onNext: { [weak self] in
                self?.registerButton.rx.isEnabled.onNext($0)
                self?.registerButton.backgroundColor = $0 ? UIColor.green : UIColor.red
            })
            .disposed(by: disposeBag)
        
    }
    
    deinit {
        print("Login VC deinitalized")
    }
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension SignUpViewController {
    
    fileprivate func setupFields() {
        usernameTextField.placeholder = "username"
        emailTextField.placeholder = "email"
        passwordTextField.placeholder = "password"
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = UIColor.gray
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor.gray
        
        let fields: [UIView] = [usernameTextField, emailTextField, passwordTextField, loginButton, registerButton]
        let stackView = UIStackView(arrangedSubviews: fields)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(300)
        }
    }
    
}

