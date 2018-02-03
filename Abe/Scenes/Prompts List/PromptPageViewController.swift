
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class PromptPageViewController: UIViewController, BindableType {
    
    var viewModel: PromptPageViewModel!
    private var dataSource: PromptPagesDataSource!
    private let disposeBag = DisposeBag()
    private var pageViewController: UIPageViewController!
    private var tabOptionsView: TabOptionsView!
    
    override func loadView() {
        super.loadView()
        setupPageController()
        setupTabOptionsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bindViewModel() {
        
        let publicTapped = tabOptionsView.button(at: 0).rx.tap
            .map { _ in Visibility.all }
            .asDriverOnErrorJustComplete()
        
        let privateTapped = tabOptionsView.button(at: 1).rx.tap
            .map { _ in Visibility.individualContacts }
            .asDriverOnErrorJustComplete()
        
        Observable.of(publicTapped, privateTapped)
            .merge()
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.tabVisSelectedInput)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.configurePagerDataSource
            .drive(onNext: { [weak self] in
                self?.configurePagerDataSource($0)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.navigateToVisibility
            .drive(onNext: { [weak self] in
                guard let controller = self?.dataSource.controllerFor(sort: $0) else {
                    fatalError("Controller not found for sort \($0)")
                }
                self?.pageViewController.setViewControllers(
                    [controller],
                    direction: .forward,
                    animated: true,
                    completion: nil
                )
                switch $0 {
                case .all: self?.tabOptionsView.currentTab = 0
                case .individualContacts: self?.tabOptionsView.currentTab = 1
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configurePagerDataSource(_ visibilites: [Visibility]) {
        self.dataSource = PromptPagesDataSource(visibilites: visibilites, navVc: self.navigationController ?? UINavigationController())
        
        self.pageViewController.dataSource = self.dataSource
        
        DispatchQueue.main.async {
            self.pageViewController.setViewControllers(
                [self.dataSource.controllerFor(index: 0)!],
                direction: .forward,
                animated: false,
                completion: nil
            )
        }
    }
    
    private func setPageViewControllerScrollEnabled(_ enabled: Bool) {
        self.pageViewController.dataSource = enabled == false ? nil : self.dataSource
    }
    
    private func setupPageController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        pageViewController.delegate = self

        pageViewController.setViewControllers(
            [.init()],
            direction: .forward,
            animated: false,
            completion: nil
        )
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController!.view.frame = view.bounds
        pageViewController.didMove(toParentViewController: self)
        view.gestureRecognizers = pageViewController.gestureRecognizers
    }
    
    private func setupTabOptionsView() {
        tabOptionsView = TabOptionsView(numberOfItems: 2)
        tabOptionsView.setTitleForButton(title: "Public", at: 0)
        tabOptionsView.setTitleForButton(title: "Private", at: 1)
        
        view.addSubview(tabOptionsView)
        tabOptionsView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view.snp.top).offset(64)
            make.height.equalTo(50)
        }
    }
    
}

extension PromptPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                                     didFinishAnimating finished: Bool,
                                     previousViewControllers: [UIViewController],
                                     transitionCompleted completed: Bool) {
    
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let idx = pendingViewControllers.first.flatMap(self.dataSource.indexFor(controller:)) else {
            return
        }
        
        self.viewModel.inputs.willTransitionToPageInput.onNext(idx)
    }
}
