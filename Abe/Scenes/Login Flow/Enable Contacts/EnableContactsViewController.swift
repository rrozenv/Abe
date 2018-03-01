
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class EnableContactsViewController: UIViewController, BindableType {
    
    var disposeBag = DisposeBag()
    var viewModel: AllowContactsViewModel!
    
    private var enableButton: UIButton!
    private var onboardingView: OnboardingView!
    private var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupBackButton()
        setupOnboardingView()
    }
    
    func bindViewModel() {
        //MARK: - Inputs
        onboardingView.button(at: 0).rx.tap.asObservable()
            .bind(to: viewModel.inputs.allowContactsTappedInput)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind(to: viewModel.inputs.backButtonTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.mainText
            .drive(onNext: { [weak self] in
                self?.onboardingView.headerLabel.text = $0.header
                self?.onboardingView.bodyLabel.text = $0.body
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.errorTracker
            .drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
}

extension EnableContactsViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func setupEnableButton() {
        enableButton = UIButton()
        enableButton.backgroundColor = UIColor.blue
        enableButton.setTitle("Enable Contacts", for: .normal)
        
        view.addSubview(enableButton)
        enableButton.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.height.equalTo(50)
            make.height.equalTo(200)
        }
    }
    
    private func setupOnboardingView() {
        onboardingView = OnboardingView(numberOfButtons: 1)
        
        onboardingView.button(at: 0).backgroundColor = Palette.brightYellow.color
        onboardingView.button(at: 0).setTitle("Enable Contacts", for: .normal)
        onboardingView.button(at: 0).setTitleColor(Palette.darkYellow.color, for: .normal)
        
        view.addSubview(onboardingView)
        onboardingView.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(0.74)
            make.center.equalTo(view)
        }
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
    
}
