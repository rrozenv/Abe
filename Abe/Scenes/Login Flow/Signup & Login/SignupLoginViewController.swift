
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class SignupLoginViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: SignupLoginViewModel!
    private var headerLabel: UILabel!
    private var bodyLabel: UILabel!
    private var dividerView: UIView!
    private var labelsStackView: UIStackView!
    private var learnMoreButton: UIButton!
    private var signupButton: UIButton!
    private var loginButton: UIButton!
    private var onboardingView: OnboardingView!
    private let widthMultiplier = 0.74
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupLoginButton()
        setupOnboardingView()
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit { print("Signup Login deinit") }
    
    func bindViewModel() {
        //MARK: - Inputs
        onboardingView.button(at: 0).rx.tap.asObservable()
            .bind(to: viewModel.inputs.learnMoreTappedInput)
            .disposed(by: disposeBag)
        
        onboardingView.button(at: 1).rx.tap.asObservable()
            .bind(to: viewModel.inputs.signupButtonTappedInput)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.loginButtonTappedInput)
            .disposed(by: disposeBag)
        
        viewModel.outputs.welcomeText
            .drive(onNext: { [weak self] in
                self?.onboardingView.headerLabel.text = $0.header
                self?.onboardingView.bodyLabel.text = $0.body
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLoginButton() {
        loginButton = UIButton()
        loginButton.backgroundColor = UIColor.clear
        loginButton.titleLabel?.font = FontBook.AvenirMedium.of(size: 13)
        loginButton.setTitle("Have an account already? Login.", for: .normal)
        loginButton.setTitleColor(Palette.lightGrey.color, for: .normal)
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.centerX.equalTo(view)
            make.height.equalTo(40)
            make.bottom.equalTo(view.snp.bottom).offset(-100)
        }
    }
    
    private func setupOnboardingView() {
        onboardingView = OnboardingView(numberOfButtons: 2)
        onboardingView.headerLabel.style(font: FontBook.AvenirBlack,
                                         size: 14,
                                         color: .black)
        
        onboardingView.bodyLabel.style(font: FontBook.AvenirMedium,
                                       size: 14,
                                       color: Palette.lightGrey.color)
        
        onboardingView.button(at: 0).style(title: "Learn More",
                                           font: FontBook.AvenirHeavy,
                                           fontSize: 13,
                                           backColor: Palette.brightYellow.color,
                                           titleColor: Palette.darkYellow.color)
        
        onboardingView.button(at: 1).style(title: "Signup",
                                           font: FontBook.AvenirHeavy,
                                           fontSize: 13,
                                           backColor: Palette.red.color,
                                           titleColor: .white)
        
        view.addSubview(onboardingView)
        onboardingView.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.centerX.equalTo(view)
            make.bottom.equalTo(loginButton.snp.top).offset(-18)
        }
    }
    
}

