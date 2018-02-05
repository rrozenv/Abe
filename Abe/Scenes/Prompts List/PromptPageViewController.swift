
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class PromptPageViewController: UIViewController {
    
    private var viewModel: PromptPageViewModel!
    private var dataSource: PromptPagesDataSource!
    private let disposeBag = DisposeBag()
    private var pageViewController: UIPageViewController!
    private var tabOptionsView: TabOptionsView!
    private var createPromptButton: UIBarButtonItem!
    
    override func loadView() {
        super.loadView()
        setupPageController()
        setupTabOptionsView()
        setupCreatePromptButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let router = PromptPageRouter(navigationController: self.navigationController!)
        viewModel = PromptPageViewModel(router: router)
        bindViewModel()
    }
    
    func bindViewModel() {
        
        //MARK: - Inputs
        let publicTapped = tabOptionsView.button(at: 0).rx.tap
            .map { _ in Visibility.all }
            .asDriverOnErrorJustComplete()
        
        let privateTapped = tabOptionsView.button(at: 1).rx.tap
            .map { _ in Visibility.individualContacts }
            .asDriverOnErrorJustComplete()
        
        Observable.of(publicTapped, privateTapped)
            .merge()
            //.distinctUntilChanged()
            .bind(to: viewModel.inputs.tabVisSelectedInput)
            .disposed(by: disposeBag)
        
        createPromptButton.rx.tap
            .bind(to: viewModel.inputs.createPromptTappedInput)
            .disposed(by: disposeBag)
            
        //MARK: - Outputs
        viewModel.outputs.configurePagerDataSource
            .drive(onNext: { [weak self] in
                self?.configurePagerDataSource($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.navigateToVisibility
            .drive(onNext: { [weak self] in
                guard let controller = self?.dataSource.controllerFor(sort: $0) else {
                    fatalError("Controller not found for sort \($0)")
                }
                var direction: UIPageViewControllerNavigationDirection = .forward
                switch $0 {
                case .all: direction = .forward
                case .individualContacts: direction = .reverse
                default: break
                }
                self?.pageViewController.setViewControllers(
                    [controller],
                    direction: direction,
                    animated: true,
                    completion: nil
                )
                self?.tabOptionsView.currentVisibility = $0
            })
            .disposed(by: disposeBag)
    }
    
    private func configurePagerDataSource(_ visibilites: [Visibility]) {
        self.dataSource = PromptPagesDataSource(visibilites: visibilites, navVc: self.navigationController!)
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
    
    private func setupCreatePromptButton() {
        createPromptButton = UIBarButtonItem(title: "Create", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = createPromptButton
    }
    
}

extension PromptPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                                     didFinishAnimating finished: Bool,
                                     previousViewControllers: [UIViewController],
                                     transitionCompleted completed: Bool) {
        viewModel.inputs.didTransitionToPageInput.onNext(completed)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let idx = pendingViewControllers.first.flatMap(self.dataSource.indexFor(controller:))
            else { return }
        viewModel.inputs.willTransitionToPageInput.onNext(idx)
    }
}
