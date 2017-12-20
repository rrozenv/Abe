
import Foundation
import RxSwift
import RxDataSources
import Action

class CreatePromptViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: CreatePromptViewModel!
    
    fileprivate var titleTextView: UITextView!
    fileprivate var bodyTextView: UITextView!
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var dismissButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupTitleTextView()
        setupBodyTextView()
        setupDoneButton()
        setupCancelButton()
        bindViewModel()
    }
    
    deinit {
        print("Create prompt deint")
    }
    
    func bindViewModel() {
        //MARK: - Input
        let input =
            CreatePromptViewModel
                .Input(title: titleTextView.rx.text.orEmpty.asObservable(),
                       body: bodyTextView.rx.text.orEmpty.asObservable(),
                       createPromptTrigger: doneButton.rx.tap.asObservable(),
                       cancelTrigger: dismissButton.rx.tap.asDriver())
        
        //MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.inputIsValid
            .drive(onNext: { [weak self] in
                self?.doneButton.isEnabled = $0 ? true : false
                self?.doneButton.tintColor = $0 ? UIColor.red : UIColor.gray
            })
            .disposed(by: disposeBag)
        
        output.promptSaved
            .drive()
            .disposed(by: disposeBag)
        
        output.dismissViewController
            .drive()
            .disposed(by: disposeBag)
    }
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension CreatePromptViewController {
    
    fileprivate func setupDoneButton() {
        doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func setupCancelButton() {
        dismissButton = UIBarButtonItem(title: "Cancel", style: .done, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = dismissButton
    }
    
    fileprivate func setupTitleTextView() {
        titleTextView = UITextView()
        //titleTextView.font = FontBook.AvenirHeavy.of(size: 14)
        titleTextView.isEditable = true
        titleTextView.isScrollEnabled = false
        titleTextView.backgroundColor = UIColor.yellow
        titleTextView.text = "Title"
        
        view.addSubview(titleTextView)
        titleTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
        }
    }
    
    fileprivate func setupBodyTextView() {
        bodyTextView = UITextView()
        //bodyTextView.font = FontBook.AvenirHeavy.of(size: 14)
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
  
}

