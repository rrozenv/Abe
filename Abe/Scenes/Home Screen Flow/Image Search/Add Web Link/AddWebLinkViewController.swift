
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
    private var activityIndicator: UIActivityIndicatorView!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupSearchTextfield()
        setupSearchButton()
    }
    
    deinit {
        print("Add Web Link deinit")
    }
    
    func bindViewModel() {
        
        //MARK: - Inputs
        searchTextField.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .bind(to: viewModel.inputs.searchTextInput)
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.searchTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.linkThumbnail
            .subscribe(onNext: { (thumbnail) in
                if let thumbnail = thumbnail {
                    print("thumbnail found: \(thumbnail)")
                } else {
                    print("no thumbnail")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.errorTracker
            .drive(onNext: { (error) in
                print("ERRROR")
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    
    }
    
    private func setupSearchTextfield() {
        searchTextField = UITextField()
        searchTextField.placeholder = "Search Images..."
        searchTextField.backgroundColor = UIColor.red
        searchTextField.layer.cornerRadius = 4.0
        searchTextField.layer.masksToBounds = true
        searchTextField.font = FontBook.AvenirMedium.of(size: 14)
        searchTextField.textColor = UIColor.black
        
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
        searchButton.backgroundColor = UIColor.blue
        searchButton.setTitle("Next", for: .normal)
        
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(searchTextField.snp.bottom).offset(10)
        }
    }
    
}

