
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class EnableContactsViewController: UIViewController, BindableType {
    
    var disposeBag = DisposeBag()
    var viewModel: AllowContactsViewModel!
    
    fileprivate var enableButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupEnableButton()
    }
    
    func bindViewModel() {
        enableButton.rx.tap.asObservable()
            .bind(to: viewModel.inputs.allowContactsTappedInput)
            .disposed(by: disposeBag)
        
        viewModel.outputs.errorTracker
            .drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
}

extension EnableContactsViewController {
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func setupEnableButton() {
        enableButton = UIButton()
        enableButton.backgroundColor = UIColor.blue
        enableButton.setTitle("Enable Contacts", for: .normal)
        
        view.addSubview(enableButton)
        enableButton.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.height.equalTo(50)
            make.height.equalTo(200)
        }
    }
    
}
