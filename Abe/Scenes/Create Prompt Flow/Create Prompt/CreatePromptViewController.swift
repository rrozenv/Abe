
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
    private var optionsBarView: TabOptionsView!
    private var backButton: UIButton!
    private var webLinkView: WebThumbnailView!
    private var removeWebLinkButton: UIButton!
    private var scrollView: UIScrollView!
    
    private var titlePlaceholderLabel: UILabel!
    private var bodyPlaceholderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupImageView()
        setupTitleTextView()
        setupScrollView()
        setupContentStackView()
        setupAddImageButton()
        setupOptionsBarView()
        setupCancelButton()
        setupBackButton()
    }

    override var inputAccessoryView: UIView? { get { return optionsBarView } }
    override var canBecomeFirstResponder: Bool { return true }
    deinit { print("Create prompt VC deint") }
    
    func bindViewModel() {
//MARK: - Input
        titleTextView.rx.text.orEmpty
            .do(onNext: { [unowned self] in self.titlePlaceholderLabel.isHidden = $0 == "" ? false : true })
            .bind(to: viewModel.inputs.titleTextInput)
            .disposed(by: disposeBag)
       
        bodyTextView.rx.text.orEmpty
            .do(onNext: { [unowned self] in self.bodyPlaceholderLabel.isHidden = $0 == "" ? false : true })
            .bind(to: viewModel.inputs.bodyTextInput)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind(to: viewModel.inputs.cancelTappedInput)
            .disposed(by: disposeBag)
        
        imageButton.rx.tap
            .bind(to: viewModel.inputs.addImageTappedInput)
            .disposed(by: disposeBag)
        
        //Add Web Link Button
        optionsBarView.button(at: 0).rx.tap
            .bind(to: viewModel.inputs.addWebLinkTappedInput)
            .disposed(by: disposeBag)
        
        //Next Button
        optionsBarView.button(at: 1).rx.tap
            .bind(to: viewModel.inputs.createTappedInput)
            .disposed(by: disposeBag)
        
        removeWebLinkButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in self.viewModel.inputs.weblinkDelegateInput.onNext(nil) })
            .disposed(by: disposeBag)
        
//MARK: - Output
        viewModel.outputs.inputIsValid
            .drive(onNext: { [weak self] in
                self?.optionsBarView.button(at: 1).isEnabled = $0
                self?.optionsBarView.button(at: 1).backgroundColor = $0 ? Palette.maroon.color : Palette.lightGrey.color
                self?.optionsBarView.button(at: 1).setTitleColor($0 ? UIColor.white : UIColor.gray, for: .normal)
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
                guard let thumbnail = $0 else {
                    self?.webLinkView.isHidden = true
                    self?.removeWebLinkButton.isHidden = true
                    self?.optionsBarView.button(at: 0).isHidden = false
                    return
                }
                self?.webLinkView.thumbnail = thumbnail
                self?.webLinkView.isHidden = false
                self?.removeWebLinkButton.isHidden = false
                self?.optionsBarView.button(at: 0).isHidden = true
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
        titleTextView.textContainer.maximumNumberOfLines = 2
        titleTextView.textContainer.lineBreakMode = .byTruncatingTail
        titleTextView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        titlePlaceholderLabel = UILabel()
        titlePlaceholderLabel.text = "Enter description..."
        titlePlaceholderLabel.textColor = UIColor.white
        
        titleTextView.addSubview(titlePlaceholderLabel)
        titlePlaceholderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleTextView).offset(5)
            make.centerY.equalTo(titleTextView)
        }
        
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
        optionsBarView = TabOptionsView(numberOfItems: 2)
        optionsBarView.button(at: 0).setTitle("+ Link", for: .normal)
        optionsBarView.button(at: 0).backgroundColor = UIColor.black
        optionsBarView.button(at: 0).setTitleColor(UIColor.white, for: .normal)
        
        optionsBarView.button(at: 1).setTitle("Next", for: .normal)
        optionsBarView.button(at: 1).backgroundColor = Palette.lightGrey.color
        optionsBarView.button(at: 1).setTitleColor(UIColor.gray, for: .normal)
        
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
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.bottom.right.equalTo(view).offset(-20)
            make.left.equalTo(view).offset(20)
            make.top.equalTo(selectedImageView.snp.bottom).offset(20)
        }
    }
    
    fileprivate func setupContentStackView() {
        webLinkView = WebThumbnailView()
        webLinkView.isHidden = true
       
        bodyTextView = UITextView()
        bodyTextView.font = FontBook.AvenirMedium.of(size: 14)
        bodyTextView.isEditable = true
        bodyTextView.isScrollEnabled = true
        bodyTextView.backgroundColor = UIColor.white
        
        bodyPlaceholderLabel = UILabel()
        bodyPlaceholderLabel.text = "Enter description..."
        bodyPlaceholderLabel.textColor = Palette.lightGrey.color
        
        bodyTextView.addSubview(bodyPlaceholderLabel)
        bodyPlaceholderLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(bodyTextView).offset(7)
        }
        
        let views: [UIView] = [webLinkView, bodyTextView]
        let contentStackView = UIStackView(arrangedSubviews: views)
        contentStackView.spacing = 10.0
        contentStackView.axis = .vertical
        
        //let imageHeight = selectedImageView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        scrollView.insertSubview(contentStackView, belowSubview: selectedImageView)
        contentStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.height.equalTo(view).multipliedBy(0.78)
            make.width.equalTo(scrollView.snp.width)
        }
        
        removeWebLinkButton = UIButton()
        removeWebLinkButton.isHidden = true
        removeWebLinkButton.setImage(#imageLiteral(resourceName: "IC_CirclePlus"), for: .normal)
        
        view.insertSubview(removeWebLinkButton, belowSubview: selectedImageView)
        removeWebLinkButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(30)
            make.right.equalTo(contentStackView).offset(10)
            make.top.equalTo(contentStackView).offset(-10)
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



