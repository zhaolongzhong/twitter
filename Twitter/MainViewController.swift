//
//  MainViewController.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 11/5/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, MenuViewControllerDelegate {
    let TAG = NSStringFromClass(MainViewController.self)
    
    @IBOutlet var menuView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var leftMarginConstraint: NSLayoutConstraint!
    
    var twitterClient: TwitterClient!
    var originalLeftMargin: CGFloat!
    var menuViewController: MenuViewController! {
        didSet {
            print("menuViewController didSet")
//            view.layoutIfNeeded()
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(oldContenViewController) {
            self.view.layoutIfNeeded()
            self.contentViewController.view.layoutIfNeeded()
            
            if oldContenViewController != nil {
                oldContenViewController.willMove(toParentViewController: nil)
                oldContenViewController.view.removeFromSuperview()
                oldContenViewController.didMove(toParentViewController: nil)
            }
            
            self.contentViewController.willMove(toParentViewController: self)
            self.contentView.addSubview(contentViewController.view)
            self.contentViewController.didMove(toParentViewController: self)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    var tweetNavigationController: UINavigationController!
    var homeViewController: HomeViewController!
    var profileViewController: ProfileViewController!
    var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.twitterClient = TwitterClient.getInstance()
       
        self.menuView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.menuView.layoutIfNeeded()
        self.contentView.layoutIfNeeded()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuViewController.delegate = self
        self.menuViewController = menuViewController
        self.addChildViewController(menuViewController)
        self.menuView.addSubview(self.menuViewController.view)
    
        self.tweetNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetNavigationController") as! UINavigationController
        self.homeViewController = self.tweetNavigationController.topViewController as! HomeViewController!
        self.profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        homeViewController.type = Tweet.homeTimeline
        self.profileViewController.user = User.getDefaultUser()
        self.profileViewController.isFromLeftBar = true
        self.viewControllers.append(self.tweetNavigationController)
        self.viewControllers.append(self.tweetNavigationController)
        self.viewControllers.append(self.profileViewController)
        self.contentViewController = self.viewControllers[0]
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translatiion = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            originalLeftMargin = leftMarginConstraint.constant
        } else if sender.state == .changed {
            leftMarginConstraint.constant = originalLeftMargin + translatiion.x
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.3, animations: {
                if velocity.x > 0 {
                    // Open
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 50
                } else {
                    // Close
                    self.leftMarginConstraint.constant = 0
                }
                self.view.layoutIfNeeded()

            })
        }
    }
    
    func menuViewController(menuViewController: MenuViewController, didSelectAt index: Int) {
        print("menu selected at \(index)")
        switch index {
        case 0:
            self.homeViewController.type = Tweet.homeTimeline
            break
        case 1:
            self.homeViewController.type = Tweet.mentionsTimeline
            break
        default:
            break
        }
        
        self.contentViewController = self.viewControllers[index]
    }
}
