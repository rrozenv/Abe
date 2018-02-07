
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
    private var customNavBar: CustomNavigationBar!
    
    override func loadView() {
        super.loadView()
        setupPageController()
        setupCustomNavigationBar()
        setupTabOptionsView()
        //setupCreatePromptButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
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
        
//        createPromptButton.rx.tap
//            .bind(to: viewModel.inputs.createPromptTappedInput)
//            .disposed(by: disposeBag)
        
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
                self?.pageViewController.setViewControllers(
                    [controller],
                    direction: .forward,
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
        tabOptionsView.setTitleForButton(title: "PUBLIC", at: 0)
        tabOptionsView.setTitleForButton(title: "PRIVATE", at: 1)
        tabOptionsView.dropShadow()
        
        view.addSubview(tabOptionsView)
        tabOptionsView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(customNavBar.snp.bottom)
            make.height.equalTo(50)
        }
    }
    
    private func setupCreatePromptButton() {
        createPromptButton = UIBarButtonItem(title: "Create", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = createPromptButton
    }
    
    func setupCustomNavigationBar() {
        customNavBar = CustomNavigationBar(leftImage: #imageLiteral(resourceName: "IC_Settings"), centerImage: #imageLiteral(resourceName: "IC_Outpost"), rightImage: #imageLiteral(resourceName: "IC_Profile"))
        
        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.height.equalTo(77)
            if #available(iOS 11.0, *) {
                if UIDevice.iPhoneX {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                }
            } else {
                make.top.equalTo(view.snp.top).offset(20)
            }
        }
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
