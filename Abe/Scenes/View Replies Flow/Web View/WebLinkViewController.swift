
import Foundation
import UIKit
import WebKit
import RxSwift
import RxCocoa

final class WebLinkViewController: UIViewController, BindableType {
 
    let disposeBag = DisposeBag()
    var viewModel: WebLinkViewModel!
    
    private var backButton: UIButton!
    private var webView: WKWebView!
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        setupBackButton()
        setupWebView()
        setupLoadingIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bindViewModel() {
        
        backButton.rx.tap
            .do(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel.outputs.webUrl
            .drive(onNext: { [weak self] (url) in
                guard let url = url else {
                    self?.showError(header: "Oops!", message: "This url is invalid. Sorry!")
                    return
                }
                let request = URLRequest(url: url)
                self?.webView.load(request)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func showError(header: String, message: String) {
        let alert = UIAlertController(title: header, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
    
    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    private func setupLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
}

extension WebLinkViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("starting")
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

}
