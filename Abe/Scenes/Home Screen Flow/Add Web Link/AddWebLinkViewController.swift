
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
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupSearchTextfield()
        //setupSearchButton()
        setupWebLinkActionButtonsView()
        setupWebThumbnailView()
        setupLoadingIndicator()
    }
    
    override var inputAccessoryView: UIView? { get { return actionButtonsView } }
    override var canBecomeFirstResponder: Bool { return true }
    deinit { print("Add Web Link deinit") }
    
    func bindViewModel() {
        
        //MARK: - Inputs
        searchTextField.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .bind(to: viewModel.inputs.searchTextInput)
            .disposed(by: disposeBag)
        
        actionButtonsView.searchButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.searchTappedInput)
            .disposed(by: disposeBag)
        
        actionButtonsView.doneButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.doneTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.linkThumbnail
            .subscribe(onNext: { [weak self] (thumbnail) in
                self?.webThumbnailView.isHidden = false
                self?.webThumbnailView.thumbnail = thumbnail
                self?.actionButtonsView.displayDone = true
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.errorTracker
            .drive(onNext: { [weak self] (error) in
                self?.handleError(error)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.activityIndicator
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.outputs.activityIndicator
            .drive(onNext: { [weak self] in
                self?.actionButtonsView.isHidden = $0 ? true : false
            })
            .disposed(by: disposeBag)
    }
    
    private func handleError(_ error: Error) {
        switch error {
        case is WebLinkThumbnailServiceError:
            print("missing info!")
        default: break
        }
    }
    
    private func setupSearchTextfield() {
        searchTextField = UITextField()
        searchTextField.placeholder = "Search Images..."
        searchTextField.backgroundColor = UIColor.red
        searchTextField.layer.cornerRadius = 4.0
        searchTextField.layer.masksToBounds = true
        searchTextField.font = FontBook.AvenirMedium.of(size: 14)
        searchTextField.textColor = UIColor.black
        searchTextField.becomeFirstResponder()
        
        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
            make.height.equalTo(view.snp.height).multipliedBy(0.11)
        }
    }
    
    private func setupSearchButton() {
        searchButton = UIButton()
        searchButton.backgroundColor = UIColor.green
        searchButton.setTitle("Next", for: .normal)

        searchButton.snp.makeConstraints { (make) in
            make.height.equalTo(100)
        }
    }
    
    private func setupWebLinkActionButtonsView() {
        actionButtonsView = WebLinkActionButtonsView()
        actionButtonsView.frame.size.height = 60
    }
    
    private func setupWebThumbnailView() {
        webThumbnailView = WebThumbnailView()
        webThumbnailView.isHidden = true
        
        view.addSubview(webThumbnailView)
        webThumbnailView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(searchTextField.snp.bottom).offset(10)
        }
    }
    
    fileprivate func setupLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
        }
    }
    
}

