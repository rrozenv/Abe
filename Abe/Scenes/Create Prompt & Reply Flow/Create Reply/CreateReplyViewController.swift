
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class CreatePromptReplyViewController: UIViewController, BindableType {
    
    var disposeBag = DisposeBag()
    var viewModel: CreateReplyViewModel!
    
    private var titleLabel: UILabel!
    private var nextButton: UIButton!
    private var backButton: UIButton!
    private var titleContainerView: UIView!
    private var bodyPlaceholderLabel: UILabel!
    private var bodyTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupBackButton()
        setupTitleLabel()
        setupBodyTextView()
        setupNextButton()
        bodyTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bodyTextView.resignFirstResponder()
    }
    
    override var inputAccessoryView: UIView? { get { return nextButton } }
    override var canBecomeFirstResponder: Bool { return true }

    deinit {
        print("create reply deinit")
    }
    
    func bindViewModel() {
        titleLabel.text = viewModel.promptTitle
        
        let input = CreateReplyViewModel.Input(body: bodyTextView.rx.text.orEmpty.asDriver(), createTrigger: nextButton.rx.tap.asDriver(), cancelTrigger: backButton.rx.tap.asDriver())
        
        bodyTextView.rx.text.orEmpty
            .do(onNext: { [unowned self] in self.bodyPlaceholderLabel.isHidden = $0 == "" ? false : true })
            .subscribe()
            .disposed(by: disposeBag)
        
        let output = viewModel.transform(input: input)
        
        output.inputIsValid
            .drive(onNext: { [weak self] in
                self?.nextButton.isHidden = $0 ? false : true
            })
            .disposed(by: disposeBag)

        output.promptDidUpdate
            .subscribe(onNext: { _ in
                print("Prompt created")
            })
            .disposed(by: disposeBag)
        
        output.loading
            .drive(onNext: { [weak self] in
                print($0)
                self?.nextButton.rx.isEnabled.onNext($0)
                //self?.postButton.backgroundColor = $0 ? UIColor.green : UIColor.blue
            })
            .disposed(by: disposeBag)
        
        output.errors
            .drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        
        output.dismissVc
            .drive()
            .disposed(by: disposeBag)
        
    }
    
}

extension CreatePromptReplyViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = Palette.brightYellow.color
        nextButton.setTitleColor(Palette.darkYellow.color, for: .normal)
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        nextButton.frame.size.height = 60
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
    
    private func setupTitleLabel() {
        titleContainerView = UIView()
        titleContainerView.backgroundColor = UIColor.white
        
        let dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = FontBook.BariolBold.of(size: 18)
        
        titleContainerView.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(titleContainerView)
            make.height.equalTo(2)
        }
        
        titleContainerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainerView)
            make.left.equalTo(titleContainerView).offset(26)
            make.right.equalTo(titleContainerView).offset(-40)
            make.bottom.equalTo(dividerView.snp.top).offset(-15)
        }
        
        view.addSubview(titleContainerView)
        titleContainerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(backButton.snp.bottom)
        }
    }
    
    func setupBodyTextView() {
        bodyTextView = UITextView()
        bodyTextView.font = FontBook.AvenirHeavy.of(size: 14)
        bodyTextView.isEditable = true
        bodyTextView.isScrollEnabled = false
        
        bodyPlaceholderLabel = UILabel()
        bodyPlaceholderLabel.text = "Write your reply..."
        bodyPlaceholderLabel.font = FontBook.AvenirMedium.of(size: 14)
        bodyPlaceholderLabel.textColor = Palette.lightGrey.color
        
        bodyTextView.addSubview(bodyPlaceholderLabel)
        bodyPlaceholderLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(bodyTextView).offset(7)
        }
        
        view.addSubview(bodyTextView)
        bodyTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(titleContainerView.snp.bottom).offset(10)
        }
    }
    
}
