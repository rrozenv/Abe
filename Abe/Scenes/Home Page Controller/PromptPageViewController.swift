
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class PromptPageViewController: UIViewController , ChildViewControllerManager {
    
    private var viewModel: PromptPageViewModel!
    private var dataSource: PromptPagesDataSource!
    private let disposeBag = DisposeBag()
    private var pageViewController: UIPageViewController!
    private var tabOptionsView: TabOptionsView!
    private var createPromptButton: UIButton!
    private var customNavBar: CustomNavigationBar!
    private var lastContentOffset: CGFloat = 0
    private var settingsViewController: SettingsViewController!
    private var settingsDisplayed = false
    
    override func loadView() {
        super.loadView()
        setupPageController()
        setupCustomNavigationBar()
        setupTabOptionsView()
        setupCreatePromptButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        let router = PromptPageRouter(navigationController: self.navigationController!)
        viewModel = PromptPageViewModel(vcType: .homeVc, router: router)
        bindViewModel()
        setupSettingsViewController()
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
        
        customNavBar.rightButton.rx.tap
            .bind(to: viewModel.inputs.profileTappedInput)
            .disposed(by: disposeBag)
        
        customNavBar.leftButton.rx.tap
            .do(onNext: { [weak self] in self?.toggleChildSettingsVc() })
            .subscribe()
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
                self?.pageViewController.setViewControllers(
                    [controller],
                    direction: .forward,
                    animated: true,
                    completion: nil
                )
                let tag = self?.getButtonTagFor(visibility: $0)
                self?.tabOptionsView.adjustButtonColors(selected: tag ?? 0,
                                                        selectedBkgColor: UIColor.black,
                                                        selectedTitleColor: UIColor.yellow,
                                                        notSelectedBkgColor: Palette.darkGrey.color,
                                                        notSelectedTitleColor: UIColor.white)
            })
            .disposed(by: disposeBag)
    }
    
    private func configurePagerDataSource(_ visibilites: [Visibility]) {
        self.dataSource = PromptPagesDataSource(visibilites: visibilites, navVc: self.navigationController!, contentOffset: 137)
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
    
    private func getButtonTagFor(visibility: Visibility) -> Int {
        switch visibility {
        case .all: return 0
        case .individualContacts: return 1
        default: return 0
        }
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
        tabOptionsView = TabOptionsView(numberOfItems: 2, height: 50.0)
        tabOptionsView.setTitleForButton(title: "PUBLIC", at: 0)
        tabOptionsView.setTitleForButton(title: "PRIVATE", at: 1)
        tabOptionsView.dropShadow()
        tabOptionsView.adjustButtonColors(selected: self.getButtonTagFor(visibility: .all),
                                                selectedBkgColor: UIColor.black,
                                                selectedTitleColor: UIColor.yellow,
                                                notSelectedBkgColor: Palette.darkGrey.color,
                                                notSelectedTitleColor: UIColor.white)
        
        view.addSubview(tabOptionsView)
        tabOptionsView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(customNavBar.snp.bottom)
            //make.height.equalTo(50)
        }
    }
    
    private func setupCreatePromptButton() {
        createPromptButton = UIButton()
        createPromptButton.setImage(#imageLiteral(resourceName: "IC_CirclePlus"), for: .normal)
        createPromptButton.dropShadow()
        
        view.addSubview(createPromptButton)
        createPromptButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(54)
            make.right.equalTo(view.snp.right).offset(-20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.bottom.equalTo(view.snp.bottom).offset(-20)
            }
        }
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

extension PromptPageViewController: SettingsDelegate {
    
    func setupSettingsViewController() {
        settingsViewController = SettingsViewController()
        settingsViewController.delegate = self
        let vm = SettingsViewModel()
        settingsViewController.setViewModelBinding(model: vm!)
        vm?.inputs.viewDidLoadInput.onNext(())
    }
    
    func closeSettings() {
        self.toggleChildSettingsVc()
    }
    
    func toggleChildSettingsVc() {
        if settingsDisplayed {
            UIView.animate(withDuration: 0.3, animations: {
                self.removeChildViewController(self.settingsViewController, completion: nil)
            })
            self.settingsDisplayed = false
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.addChildViewController(self.settingsViewController, frame: self.view.frame, animated: false)
            })
            self.settingsDisplayed = true
        }
    }
    
}

//extension PromptPageViewController: UIScrollViewDelegate {
//
//    fileprivate func animateTabBar(isScrollingUp: Bool) {
//        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
//            if isScrollingUp {
////                self.filterHeaderView.layer.opacity = 1
////                self.filterHeaderView.backgroundView.layer.opacity = 1
//            } else {
////                self.filterHeaderView.layer.opacity = 0
////                self.filterHeaderView.backgroundView.layer.opacity = 0
//            }
//        }, completion: nil)
//    }
//
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.lastContentOffset = scrollView.contentOffset.y
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
////        guard self.lastContentOffset != 0 else {
////            animateTabBar(isScrollingUp: true)
////            return
////        }
////        if (self.lastContentOffset < scrollView.contentOffset.y) {
////            animateTabBar(isScrollingUp: false)
////        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
////            animateTabBar(isScrollingUp: true)
////        }
//    }
//
//}

