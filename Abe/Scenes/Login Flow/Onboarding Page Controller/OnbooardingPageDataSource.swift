
import Foundation
import UIKit

enum OnboardingPage: Int {
    case one = 1
    case two = 2
    
    static func totalCount() -> Int {
        return OnboardingPage.two.rawValue
    }
}

extension OnboardingPage: Equatable {
    static func ==(lhs: OnboardingPage, rhs: OnboardingPage) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension OnboardingPage: Hashable {
    var hashValue: Int {
        return rawValue.hashValue
    }
}

final class OnboardingPageDataSource: NSObject, UIPageViewControllerDataSource {
    
    private var viewControllers: [UIViewController]
    private let pages: [OnboardingPage]
    
    internal init(pages: [OnboardingPage], viewController: OnboardingPageViewController) {
        self.pages = pages
        self.viewControllers = pages.map { OnboardingViewController.configuredWith(page: $0, delegate: viewController) }
    }

    internal func indexFor(controller: UIViewController) -> Int? {
        return self.viewControllers.index(of: controller)
    }
    
    internal func pageFor(controller: UIViewController) -> OnboardingPage? {
        return self.indexFor(controller: controller).map { self.pages[$0] }
    }
    
    internal func controllerFor(index: Int) -> UIViewController? {
        guard index >= 0 && index < self.viewControllers.count else { return nil }
        return self.viewControllers[index]
    }
    
    internal func controllerFor(page: OnboardingPage) -> UIViewController? {
        guard let index = self.pages.index(of: page) else { return nil }
        return self.viewControllers[index]
    }
    
    internal func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let pageIdx = self.viewControllers.index(of: viewController) else {
            fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
        }
        
        let nextPageIdx = pageIdx + 1
        guard nextPageIdx < self.viewControllers.count else {
            return nil
        }
        
        return self.viewControllers[nextPageIdx]
    }
    
    internal func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let pageIdx = self.viewControllers.index(of: viewController) else {
            fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
        }
        
        let previousPageIdx = pageIdx - 1
        guard previousPageIdx >= 0 else {
            return nil
        }
        
        return self.viewControllers[previousPageIdx]
    }
}
