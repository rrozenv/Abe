
import Foundation
import UIKit
import RxCocoa
import RxSwift

final class CreateUserViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var viewModel: CreateUserViewModel!
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        setupLoadingIndicator()
    }
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppearInput.onNext(())
    }

    deinit { print("Add Web Link deinit") }
    
    func bindViewModel() {
        //MARK: - Outputs
        viewModel.outputs.errorTracker
            .drive(onNext: { [weak self] (error) in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.activityIndicator
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
        }
    }
    
}
