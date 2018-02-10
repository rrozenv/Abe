
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class SignupLoginViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: SignupLoginViewModel!
    private var signupButton: UIButton!
    private var loginButton: UIButton!
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupLoginButton()
        setupSignupButton()
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit { print("Signup Login deinit") }
    
    func bindViewModel() {
        //MARK: - Inputs
        signupButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.signupButtonTappedInput)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.loginButtonTappedInput)
            .disposed(by: disposeBag)
    }
    
    private func setupLoginButton() {
        loginButton = UIButton()
        loginButton.backgroundColor = UIColor.red
        loginButton.setTitle("Login", for: .normal)
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.snp.bottom).offset(-100)
        }
    }
    
    private func setupSignupButton() {
        signupButton = UIButton()
        signupButton.backgroundColor = UIColor.blue
        signupButton.setTitle("Signup", for: .normal)
        
        view.addSubview(signupButton)
        signupButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(50)
            make.bottom.equalTo(loginButton.snp.top).offset(-20)
        }
    }
    
}

