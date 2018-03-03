
import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol OnboardingViewControllerDelegate: class {
    func didTapNextButton()
}

final class OnboardingViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: OnboardingViewModel!
    private var onboardingView: OnboardingView!
    private let widthMultiplier = 0.74
    weak var delegate: OnboardingViewControllerDelegate?
    
    static func configuredWith(page: OnboardingPage, delegate: OnboardingPageViewController) -> OnboardingViewController {
        var vc = OnboardingViewController()
        vc.delegate = delegate
        let viewModel = OnboardingViewModel(page: page)
        vc.setViewModelBinding(model: viewModel)
        vc.viewModel.inputs.viewDidLoadInput.onNext(())
        return vc
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupOnboardingView()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit { print("Onboaridng deinit") }
    
    func bindViewModel() {
        //MARK: - Inputs
        onboardingView.button(at: 0).rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.delegate?.didTapNextButton()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.pageInfo
            .drive(onNext: { [weak self] in
                self?.onboardingView.headerLabel.text = $0.header
                self?.onboardingView.bodyLabel.text = $0.body
                self?.onboardingView.button(at: 0).setTitle($0.buttonTitle, for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupOnboardingView() {
        onboardingView = OnboardingView(numberOfButtons: 1)
        onboardingView.headerLabel.style(font: FontBook.AvenirBlack,
                                         size: 14,
                                         color: .black)
        
        onboardingView.bodyLabel.style(font: FontBook.AvenirMedium,
                                       size: 14,
                                       color: Palette.lightGrey.color)
        
        onboardingView.button(at: 0).style(title: "",
                                           font: FontBook.AvenirHeavy,
                                           fontSize: 13,
                                           backColor: Palette.brightYellow.color,
                                           titleColor: Palette.darkYellow.color)
        
        view.addSubview(onboardingView)
        onboardingView.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.center.equalTo(view)
        }
    }
    
}
