
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class CreatePromptReplyViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    var viewModel: CreateReplyViewModel!
    
    var postButton: UIButton!
    var bodyTextView: UITextView!
    var titleTextView: UITextView!
    var backButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        setupTitleTextView()
        setupBodyTextView()
        setupPostButton()
        setupCancelButton()
        bodyTextView.becomeFirstResponder()
        bindViewModel()
    }
    
    deinit {
        print("create reply deinit")
    }
    
    func bindViewModel() {
        titleTextView.text = viewModel.promptTitle
        
        let input = CreateReplyViewModel.Input(body: bodyTextView.rx.text.orEmpty.asDriver(), createTrigger: postButton.rx.tap.asDriver(), cancelTrigger: backButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.inputIsValid
            .drive(onNext: { [weak self] in
                self?.postButton.isEnabled = $0 ? true : false
                self?.postButton.backgroundColor = $0 ? UIColor.blue : UIColor.gray
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
                self?.postButton.rx.isEnabled.onNext($0)
                self?.postButton.backgroundColor = $0 ? UIColor.green : UIColor.blue
            })
            .disposed(by: disposeBag)
        
        output.errors
            .drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        
    }
    
}

extension CreatePromptReplyViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupCancelButton() {
        backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func setupTitleTextView() {
        titleTextView = UITextView()
        titleTextView.font = FontBook.AvenirHeavy.of(size: 14)
        titleTextView.isEditable = false
        titleTextView.isScrollEnabled = false
        titleTextView.backgroundColor = UIColor.yellow
        
        view.addSubview(titleTextView)
        titleTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
        }
    }
    
    func setupBodyTextView() {
        bodyTextView = UITextView()
        bodyTextView.font = FontBook.AvenirHeavy.of(size: 14)
        bodyTextView.isEditable = true
        bodyTextView.isScrollEnabled = false
        bodyTextView.backgroundColor = UIColor.yellow
        bodyTextView.text = "body"
        
        view.addSubview(bodyTextView)
        bodyTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(titleTextView.snp.bottom).offset(10)
        }
    }
    
    func setupPostButton() {
        postButton = UIButton()
        postButton.backgroundColor = UIColor.blue
        postButton.setTitle("Next", for: .normal)
        
        view.addSubview(postButton)
        postButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(bodyTextView.snp.bottom).offset(10)
        }
    }
    
}
