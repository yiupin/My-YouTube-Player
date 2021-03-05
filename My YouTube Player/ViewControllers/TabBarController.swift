//
//  ViewController.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 24/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController   {
    
    override var shouldAutorotate: Bool {
        return self.selectedViewController?.shouldAutorotate ?? false
    }
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let configuration = UIImage.SymbolConfiguration(weight: .bold)
        
        let playlistsVC = PlaylistsViewController()
        let playlistsController = CustomNavigationController(rootViewController: playlistsVC)
        playlistsController.tabBarItem.image = UIImage(systemName: "music.note.list", withConfiguration: configuration)
        playlistsController.tabBarItem.title = "Playlists"
        
        let searchVC = SearchViewController()
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass", withConfiguration: configuration)
        searchVC.tabBarItem.title = "Search"
        
        let playerVC = PlayerViewController()
        playerVC.tabBarItem.image = UIImage(systemName: "music.note", withConfiguration: configuration)
        playerVC.tabBarItem.title = "Now Playing"
        
        viewControllers = [playlistsController, searchVC, playerVC]
        
        // Tab bar appearance
        tabBar.barTintColor = .black
        tabBar.unselectedItemTintColor = .white
        tabBar.tintColor = .white
        
        if let tabBarItems = tabBar.items {
            let numberOfItems = tabBarItems.count
            if numberOfItems > 0 {
                let tabBarItemSize = CGSize(width: tabBar.frame.width / CGFloat(numberOfItems), height: tabBar.frame.height)
                tabBar.selectionIndicatorImage = UIImage.imageWithColor(.red, size: tabBarItemSize, cornerRadius: 5)
            }
        }
        
        // Handle App enters background and foreground
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { sender in
            self.delegate = nil
            self.currentIndex = self.selectedIndex
            self.selectedIndex = 0
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { sender in
            self.selectedIndex = self.currentIndex
            self.delegate = self
        }
    }
}

extension TabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return customtabBarTransition(viewControllers: tabBarController.viewControllers)
        }

}


class customtabBarTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.3
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart

        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }

    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}


