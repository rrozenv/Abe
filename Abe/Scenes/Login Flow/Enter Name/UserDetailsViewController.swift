
import Foundation
import RxSwift
import RxDataSources
import Action

class UserDetailsViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: UserDetailsViewModel!
    
    private var onboardingView: OnboardingView!
    fileprivate var firstNameTextField: PaddedTextField!
    fileprivate var lastNameTextField: PaddedTextField!
    fileprivate var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupOnboardingView()
        setupTitleTextView()
        setupBodyTextView()
        setupNextButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstNameTextField.becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? { get { return nextButton } }
    override var canBecomeFirstResponder: Bool { return true }
    deinit { print("Create prompt deint") }
    
    func bindViewModel() {
        //MARK: - Input
        firstNameTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.firstNameTextInput)
            .disposed(by: disposeBag)
        
        lastNameTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.lastNameTextInput)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(to: viewModel.inputs.nextButtonTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.mainText
            .drive(onNext: { [weak self] in
                self?.onboardingView.headerLabel.text = $0.header
                self?.onboardingView.bodyLabel.text = $0.body
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.inputIsValid
            .drive(onNext: { [weak self] in
                self?.nextButton.isHidden = $0 ? false : true
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension UserDetailsViewController {
    
    private func setupOnboardingView() {
        onboardingView = OnboardingView(numberOfButtons: 0)
 
        view.addSubview(onboardingView)
        onboardingView.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(0.74)
            make.centerX.equalTo(view)
            make.top.equalTo(view.snp.top).offset(160)
        }
    }
    
    fileprivate func setupTitleTextView() {
        firstNameTextField = PaddedTextField()
        firstNameTextField.style(placeHolder: "First Name...",
                                 font: FontBook.AvenirMedium,
                                 fontSize: 14,
                                 backColor: Palette.faintGrey.color,
                                 titleColor: .black)
        
        firstNameTextField.layer.cornerRadius = 2.0
        firstNameTextField.layer.masksToBounds = true
        
        view.addSubview(firstNameTextField)
        firstNameTextField.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(0.74)
            make.centerX.equalTo(view)
            make.height.equalTo(50)
            make.top.equalTo(onboardingView.snp.bottom).offset(10)
        }
    }
    
    fileprivate func setupBodyTextView() {
        lastNameTextField = PaddedTextField()
        lastNameTextField.placeholder = "Last Name..."
        lastNameTextField.backgroundColor = Palette.faintGrey.color
        lastNameTextField.layer.cornerRadius = 2.0
        lastNameTextField.layer.masksToBounds = true
        lastNameTextField.font = FontBook.AvenirMedium.of(size: 14)
        lastNameTextField.textColor = UIColor.black
        
        view.addSubview(lastNameTextField)
        lastNameTextField.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(0.74)
            make.centerX.equalTo(view)
            make.height.equalTo(50)
            make.top.equalTo(firstNameTextField.snp.bottom).offset(10)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = Palette.brightYellow.color
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(Palette.darkYellow.color, for: .normal)
        nextButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        nextButton.frame.size.height = 50
    }
    
}

