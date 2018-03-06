
import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol BindableType {
    associatedtype ViewModelType
    var viewModel: ViewModelType! { get set }
    func bindViewModel()
}

extension BindableType where Self: UIViewController {
    mutating func setViewModelBinding(model: Self.ViewModelType) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}

final class AddWebLinkViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: AddWebLinkViewModel!
    private var searchTextField: UITextField!
    private var searchButton: UIButton!
    private var actionButtonsView: WebLinkActionButtonsView!
    private var webThumbnailView: WebThumbnailView!
    private var removeWebLinkButton: UIButton!
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    
    // MARK: - View Life Cycle
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        setupSearchTextfield()
        setupWebLinkActionButtonsView()
        setupWebThumbnailView()
        setupStackView()
        setupRemoveWebLinKButton()
        setupBackButton()
        setupTitleLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    deinit { print("Add Web Link deinit") }
    
    func bindViewModel() {
        
        //MARK: - Inputs
        searchTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.searchTextInput)
            .disposed(by: disposeBag)
        
        actionButtonsView.searchButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .filter { [unowned self] in self.searchTextField.text?.isNotEmpty ?? false }
            .bind(to: viewModel.inputs.searchTappedInput)
            .disposed(by: disposeBag)
        
        actionButtonsView.doneButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.doneTappedInput)
            .disposed(by: disposeBag)
        
        removeWebLinkButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.removeWebLinkTappedInput)
            .disposed(by: disposeBag)
        
        backButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.backButtonTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.linkThumbnail
            .drive(onNext: { [weak self] (thumbnail) in
                let thumbnailExists = (thumbnail != nil)
                self?.webThumbnailView.thumbnail = thumbnail
                self?.removeWebLinkButton.isHidden = thumbnailExists ? false : true
                self?.webThumbnailView.placeholderBackgroundView.isHidden = thumbnailExists ? true : false
                self?.webThumbnailView.placeholderImageView.isHidden = thumbnailExists ? true : false
                self?.actionButtonsView.displayDone = thumbnailExists ? true : false
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.searchTextIsValid
            .drive(onNext: { [weak self] in
                if !$0 { self?.searchTextField.text = nil }
                self?.actionButtonsView.searchButton.backgroundColor = $0 ? UIColor.black : Palette.lightGrey.color
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.errorTracker
            .drive(onNext: { [weak self] (error) in self?.handleError(error) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.activityIndicator
            .drive(webThumbnailView.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.outputs.activityIndicator
            .drive(onNext: { [weak self] in
                self?.webThumbnailView.placeholderBackgroundView.isHidden = false
                self?.webThumbnailView.placeholderImageView.isHidden = $0 ? true : false
            })
            .disposed(by: disposeBag)
    }
    
    private func handleError(_ error: Error) {
        switch error {
        case is WebLinkThumbnailServiceError: print("missing info!")
        default: print("there was an error!")
        }
        let header = "Oops!"
        let message = "Sorry, it seems like we couldn't find this link. Please check you enterted the URL properly."
        let alert = UIAlertController(title: header, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupSearchTextfield() {
        searchTextField = UITextField()
        searchTextField.placeholder = "Paste or Type Web URL..."
        searchTextField.backgroundColor = Palette.faintGrey.color
        searchTextField.layer.cornerRadius = 2.0
        searchTextField.layer.masksToBounds = true
        searchTextField.font = FontBook.AvenirMedium.of(size: 14)
        searchTextField.textColor = UIColor.black
        searchTextField.becomeFirstResponder()
        
        searchTextField.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
    }
    
    private func setupWebLinkActionButtonsView() {
        actionButtonsView = WebLinkActionButtonsView()
        actionButtonsView.doneButton.backgroundColor = Palette.brightYellow.color
        actionButtonsView.doneButton.setTitleColor(Palette.darkYellow.color, for: .normal)
        actionButtonsView.searchButton.backgroundColor = Palette.lightGrey.color
        actionButtonsView.searchButton.setTitleColor(UIColor.white, for: .normal)
        
        actionButtonsView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
    }
    
    private func setupWebThumbnailView() {
        webThumbnailView = WebThumbnailView()
    }
    
    private func setupRemoveWebLinKButton() {
        removeWebLinkButton = UIButton()
        removeWebLinkButton.isHidden = true
        removeWebLinkButton.setImage(#imageLiteral(resourceName: "IC_RedCancelCircle"), for: .normal)
        
        view.insertSubview(removeWebLinkButton, aboveSubview: webThumbnailView)
        removeWebLinkButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(30)
            make.right.equalTo(webThumbnailView).offset(10)
            make.top.equalTo(webThumbnailView).offset(-10)
        }
    }
    
    private func setupStackView() {
        let views: [UIView] = [searchTextField, webThumbnailView, actionButtonsView]
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(26)
            make.right.equalTo(view).offset(-26)
            make.centerY.equalTo(view).offset(-100)
            make.centerX.equalTo(view)
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
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Add Web Link"
        titleLabel.font = FontBook.AvenirHeavy.of(size: 14)
        titleLabel.textColor = UIColor.black
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backButton).offset(12)
            make.centerX.equalTo(view)
        }
    }

}

extension UIButton {
    
    static func backButton(image: UIImage) -> UIButton {
        image.size.equalTo(CGSize(width: 9, height: 17))
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 9, height: 17))
        backButton.setImage(image, for: .normal)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 36, left: 26, bottom: 15, right: 15)
        return backButton
    }
    
    static func cancelButton(image: UIImage) -> UIButton {
        image.size.equalTo(CGSize(width: 17, height: 17))
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        backButton.setImage(image, for: .normal)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 36, left: 26, bottom: 15, right: 26)
        return backButton
    }
    
}


