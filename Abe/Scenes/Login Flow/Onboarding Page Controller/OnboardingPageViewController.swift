
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class OnboardingPageViewController: UIViewController {
    
    private var dataSource: OnboardingPageDataSource!
    private let disposeBag = DisposeBag()
    private var pageViewController: UIPageViewController!
    private var doneButton: UIButton!
    private var pageIndicatorView: PageIndicatorView!
    private var currentPageIndex = 0
    
    override func loadView() {
        super.loadView()
        setupPageController()
        setupDoneButton()
        setupPageIndicator(total: OnboardingPage.totalCount())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        configurePagerDataSource()
    }
    
    deinit { print("Onboarding Page VC deinit") }
    
    private func transitionTo(viewController: UIViewController) {
        let currentPageIndex = dataSource.indexFor(controller: viewController) ?? 0
        self.currentPageIndex = currentPageIndex
        self.pageIndicatorView.currentPage = currentPageIndex
        self.pageViewController.setViewControllers(
            [viewController],
            direction: .forward,
            animated: true,
            completion: nil
        )
    }
    
    private func configurePagerDataSource() {
        let pages: [OnboardingPage] = [.one, .two]
        self.dataSource = OnboardingPageDataSource(pages: pages, viewController: self)
        self.pageViewController.dataSource = self.dataSource
        self.pageIndicatorView.currentPage = 0
        DispatchQueue.main.async {
            self.pageViewController.setViewControllers(
                [self.dataSource.controllerFor(index: 0)!],
                direction: .forward,
                animated: false,
                completion: nil
            )
        }
    }

}

extension OnboardingPageViewController {
    
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
    
    private func setupDoneButton() {
        doneButton = UIButton.cancelButton(image: #imageLiteral(resourceName: "IC_BlackX"))
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
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
    
    func setupPageIndicator(total: Int) {
        let widthHeight: CGFloat = 6.0
        
        func widthForStackView(numberOfPages: Int) -> CGFloat {
            let spacing: CGFloat = 10.0
            let spacingMultiplier = CGFloat(numberOfPages - 1)
            let widthMultiplier = CGFloat(numberOfPages)
            return (spacing * spacingMultiplier) + (widthHeight * widthMultiplier)
        }
        
        pageIndicatorView = PageIndicatorView(numberOfItems: total, widthHeight: 6.0)
        
        view.addSubview(pageIndicatorView)
        pageIndicatorView.snp.makeConstraints { (make) in
            make.left.equalTo(doneButton.snp.right).offset(10)
            make.centerY.equalTo(doneButton.snp.centerY).offset(10)
            make.height.equalTo(6.0)
            make.width.equalTo(widthForStackView(numberOfPages: total))
        }
    }
    
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let idx = pendingViewControllers.first.flatMap(self.dataSource.indexFor(controller:)),
              let vc = dataSource.controllerFor(index: idx)
              else { return }
        self.transitionTo(viewController: vc)
    }
    
}

extension OnboardingPageViewController: OnboardingViewControllerDelegate {
    
    func didTapNextButton() {
        guard let currentViewController = dataSource.controllerFor(index: currentPageIndex),
              let nextVc = dataSource.pageViewController(pageViewController, viewControllerAfter: currentViewController) else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.transitionTo(viewController: nextVc)
    }
    
}
