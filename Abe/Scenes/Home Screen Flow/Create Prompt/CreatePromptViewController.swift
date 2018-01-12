
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
    private var imageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupTitleTextView()
        setupBodyTextView()
        setupAddImageButton()
        setupDoneButton()
        setupCancelButton()
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("VC Ref count: \(CFGetRetainCount(self))")
        print("ViewModel Ref count: \(CFGetRetainCount(viewModel))")
    }
    
    deinit {
        print("Create prompt deint")
    }
    
    func bindViewModel() {
//MARK: - Input
        titleTextView.rx.text.orEmpty
            .bind(to: viewModel.inputs.title)
            .disposed(by: disposeBag)
       
        bodyTextView.rx.text.orEmpty
            .bind(to: viewModel.inputs.body)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind(to: viewModel.inputs.createPromptTrigger)
            .disposed(by: disposeBag)
        
        dismissButton.rx.tap
            .bind(to: viewModel.inputs.cancelTrigger)
            .disposed(by: disposeBag)
        
        imageButton.rx.tap
            .bind(to: viewModel.inputs.addImageTapped)
            .disposed(by: disposeBag)
        
//MARK: - Output
        viewModel.outputs.inputIsValid
            .drive(onNext: { [weak self] in
                self?.doneButton.isEnabled = $0 ? true : false
                self?.doneButton.tintColor = $0 ? UIColor.red : UIColor.gray
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.dismissViewController
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.outputs.routeToAddImage
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.outputs.didAddImage
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
    
    func setupAddImageButton() {
        imageButton = UIButton()
        imageButton.backgroundColor = UIColor.blue
        imageButton.setTitle("Add Image", for: .normal)
        
        view.addSubview(imageButton)
        imageButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(bodyTextView.snp.bottom).offset(10)
        }
    }
  
}

