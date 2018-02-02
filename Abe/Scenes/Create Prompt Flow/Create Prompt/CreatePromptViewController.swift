
import Foundation
import RxSwift
import RxDataSources
import Kingfisher

class CreatePromptViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: CreatePromptViewModel!
    
    private var selectedImageView: UIImageView!
    private var titleTextView: UITextView!
    private var bodyTextView: UITextView!
    private var doneButton: UIBarButtonItem!
    private var dismissButton: UIBarButtonItem!
    private var imageButton: UIButton!
    private var addWebLinkButton: UIButton!
    private var optionsBarView: CreatePromptOptionsBarView!
    private var backButton: UIButton!
    private var webLinkView: WebThumbnailView!
    private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupImageView()
        setupTitleTextView()
        setupScrollView()
        setupContentStackView()
        setupAddImageButton()
        setupOptionsBarView()
        setupDoneButton()
        setupCancelButton()
        setupBackButton()
    }

    override var inputAccessoryView: UIView? { get { return optionsBarView } }
    override var canBecomeFirstResponder: Bool { return true }
    deinit { print("Create prompt VC deint") }
    
    func bindViewModel() {
//MARK: - Input
        titleTextView.rx.text.orEmpty
            .bind(to: viewModel.inputs.titleTextInput)
            .disposed(by: disposeBag)
       
        bodyTextView.rx.text.orEmpty
            .bind(to: viewModel.inputs.bodyTextInput)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind(to: viewModel.inputs.createTappedInput)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind(to: viewModel.inputs.cancelTappedInput)
            .disposed(by: disposeBag)
        
        imageButton.rx.tap
            .bind(to: viewModel.inputs.addImageTappedInput)
            .disposed(by: disposeBag)
        
        optionsBarView.addWebLinkButton.rx.tap
            .bind(to: viewModel.inputs.addWebLinkTappedInput)
            .disposed(by: disposeBag)
        
//MARK: - Output
        viewModel.outputs.inputIsValid
            .drive(onNext: { [weak self] in
                self?.doneButton.isEnabled = $0 ? true : false
                self?.doneButton.tintColor = $0 ? UIColor.red : UIColor.gray
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.imageDelegateOutput
            .drive(onNext: { [weak self] in
                guard let image = $0 else { return }
                guard let url = URL(string: image.webformatURL) else { return }
                self?.selectedImageView.kf.setImage(with: url)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.weblinkDelegateOutput
            .drive(onNext: { [weak self] in
                guard let thumbnail = $0 else { return }
                self?.webLinkView.thumbnail = thumbnail
                self?.webLinkView.isHidden = false
            })
            .disposed(by: disposeBag)
        
        UIDevice.keyboardHeight()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.scrollView.contentInset = UIEdgeInsetsMake(0, 0, $0, 0)
                print($0)
            })
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
    
    fileprivate func setupImageView() {
        selectedImageView = UIImageView()
        selectedImageView.contentMode = .scaleAspectFill
        selectedImageView.clipsToBounds = true
        selectedImageView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.addSubview(selectedImageView)
        selectedImageView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.height.equalTo(view).multipliedBy(0.22)
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
    
    fileprivate func setupTitleTextView() {
        titleTextView = UITextView()
        titleTextView.font = FontBook.AvenirHeavy.of(size: 16)
        titleTextView.textColor = UIColor.white
        titleTextView.isEditable = true
        titleTextView.isScrollEnabled = false
        titleTextView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        titleTextView.text = "Enter Title..."
        titleTextView.textContainer.maximumNumberOfLines = 3
        titleTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        view.insertSubview(titleTextView, aboveSubview: selectedImageView)
        titleTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.bottom.equalTo(selectedImageView.snp.bottom).offset(-20)
        }
    }
    
    func setupAddImageButton() {
        imageButton = UIButton()
        imageButton.setTitle("+ GIF", for: .normal)
        imageButton.setTitleColor(UIColor.white, for: .normal)
        imageButton.titleLabel?.font = FontBook.BariolBold.of(size: 22)
        imageButton.sizeToFit()
        
        view.addSubview(imageButton)
        imageButton.snp.makeConstraints { (make) in
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(selectedImageView.snp.top).offset(20)
        }
    }
    
    func setupOptionsBarView() {
        optionsBarView = CreatePromptOptionsBarView()
        optionsBarView.addWebLinkButton.setTitle("Add Web Link", for: .normal)
        optionsBarView.nextButton.setTitle("Next", for: .normal)
        optionsBarView.frame.size.height = 54
        optionsBarView.frame.size.width = view.frame.size.width
    }
    
    private func setupBackButton() {
        let image = #imageLiteral(resourceName: "IC_BackArrow")
        image.size.equalTo(CGSize(width: 9, height: 17))
        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 9, height: 17))
        backButton.setImage(image, for: .normal)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 26, left: 20, bottom: 15, right: 15)
        
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
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(selectedImageView.snp.bottom)
        }
    }
    
    fileprivate func setupContentStackView() {
        webLinkView = WebThumbnailView()
        webLinkView.isHidden = true
        
        bodyTextView = UITextView()
        bodyTextView.font = FontBook.AvenirMedium.of(size: 14)
        bodyTextView.isEditable = true
        bodyTextView.isScrollEnabled = true
        bodyTextView.backgroundColor = UIColor.yellow
        bodyTextView.text = "Enter description..."
        
        let views: [UIView] = [webLinkView, bodyTextView]
        let contentStackView = UIStackView(arrangedSubviews: views)
        contentStackView.spacing = 4.0
        contentStackView.axis = .vertical
        //let imageHeight = selectedImageView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        scrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.height.equalTo(view).multipliedBy(0.78)
            make.width.equalTo(view.snp.width)
//            make.left.equalTo(view).offset(20)
//            make.right.equalTo(view).offset(-20)
//            make.top.equalTo(selectedImageView.snp.bottom).offset(20)
        }
    }
    
    
  
}

extension UIDevice {
    static var iPhoneX: Bool { return UIScreen.main.nativeBounds.height == 2436 }
    
    static func keyboardHeight() -> Observable<CGFloat> {
        return Observable
            .from([ NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
                .map { notification -> CGFloat in
                    (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                },
                    NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
                        .map { _ -> CGFloat in
                            0
                }
                ])
            .merge()
    }
}



