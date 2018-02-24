
import Foundation
import UIKit

final class PromptPagesDataSource: NSObject, UIPageViewControllerDataSource {
    
    private var viewControllers: [UIViewController]
    private let visibilites: [Visibility]
    
    internal init(visibilites: [Visibility],
                  navVc: UINavigationController,
                  contentOffset: CGFloat) {
        self.visibilites = visibilites
        self.viewControllers = visibilites
            .map { PromptsListViewController
                .configuredWith(visibility: $0,
                                navVc: navVc,
                                contentOffset: contentOffset)
            }
    }
    
//    internal func load(filter: DiscoveryParams) {
//        self.viewControllers
//            .flatMap { $0 as? DiscoveryPageViewController }
//            .forEach { $0.change(filter: filter) }
//    }
    
    internal func indexFor(controller: UIViewController) -> Int? {
        return self.viewControllers.index(of: controller)
    }
    
    internal func visibilityFor(controller: UIViewController) -> Visibility? {
        return self.indexFor(controller: controller).map { self.visibilites[$0] }
    }
    
    internal func controllerFor(index: Int) -> UIViewController? {
        guard index >= 0 && index < self.viewControllers.count else { return nil }
        return self.viewControllers[index]
    }
    
    internal func controllerFor(sort: Visibility) -> UIViewController? {
        guard let index = self.visibilites.index(of: sort) else { return nil }
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
