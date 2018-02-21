
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ProfileViewController: UIViewController {
    
    private var viewModel: ProfileViewModel!
    private var dataSource: PromptPagesDataSource!
    private let disposeBag = DisposeBag()
    private var pageViewController: UIPageViewController!
    private var tabOptionsView: TabOptionsView!
    private var createPromptButton: UIButton!
    private var profileHeaderView: ProfileHeaderView!
    private var cancelButton: UIButton!
    private var lastContentOffset: CGFloat = 0
    
    override func loadView() {
        super.loadView()
        setupPageController()
        setupProfileHeaderView()
        setupCancelButton()
        setupTabOptionsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        let router = ProfileRouter(navigationController: self.navigationController!)
        viewModel = ProfileViewModel(router: router)
        bindViewModel()
    }
    
    deinit { print("Profile VC deinit") }
    
    func bindViewModel() {
        
        //MARK: - Inputs
        let publicTapped = tabOptionsView.button(at: 0).rx.tap
            .map { _ in Visibility.currentUserReplied }
            .asDriverOnErrorJustComplete()
        
        let privateTapped = tabOptionsView.button(at: 1).rx.tap
            .map { _ in Visibility.currentUserCreated }
            .asDriverOnErrorJustComplete()
        
        Observable.of(publicTapped, privateTapped)
            .merge()
            .bind(to: viewModel.inputs.tabVisSelectedInput)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: viewModel.inputs.cancelTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.currentUser
            .drive(onNext: { [weak self] in
                self?.profileHeaderView.populateInfoWith(currentUser: $0)
                self?.profileHeaderView.setNeedsLayout()
            })
            .disposed(by: disposeBag)
        
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
    
    private func getButtonTagFor(visibility: Visibility) -> Int {
        switch visibility {
        case .currentUserReplied: return 0
        case .currentUserCreated: return 1
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
        tabOptionsView.setTitleForButton(title: "REPLIED", at: 0)
        tabOptionsView.setTitleForButton(title: "CREATED", at: 1)
        tabOptionsView.dropShadow()
        tabOptionsView.adjustButtonColors(selected: self.getButtonTagFor(visibility: .all),
                                          selectedBkgColor: UIColor.black,
                                          selectedTitleColor: UIColor.yellow,
                                          notSelectedBkgColor: Palette.darkGrey.color,
                                          notSelectedTitleColor: UIColor.white)
        
        view.addSubview(tabOptionsView)
        tabOptionsView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(profileHeaderView.snp.bottom)
            //make.height.equalTo(50)
        }
    }

    func setupProfileHeaderView() {
        profileHeaderView = ProfileHeaderView()
        
        view.addSubview(profileHeaderView)
        profileHeaderView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
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
    
    private func setupCancelButton() {
        cancelButton = UIButton.cancelButton(image: #imageLiteral(resourceName: "IC_BlackX"))
        
        profileHeaderView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right)
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
    
}

extension ProfileViewController: UIPageViewControllerDelegate {
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
