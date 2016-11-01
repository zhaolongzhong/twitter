//
//  WelcomeViewController.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/28/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var loginButton: UIButton!

    let tabBarControllerSegueId = "TabBarControllerSegueId"
    
    var twitterClient: TwitterClient?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.twitterClient = TwitterClient.getInstance()
        print("twitterClient is \(twitterClient)")
        
        if self.twitterClient != nil {
            self.performSegue(withIdentifier: self.tabBarControllerSegueId, sender: nil)
        }
        
        signUpButton.backgroundColor = UIColor.white
        signUpButton.layer.cornerRadius = 8
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.white.cgColor
    }

    
    @IBAction func loginButtonAction(_ sender: AnyObject) {
        TwitterClient.login(success: { () -> () in
            self.performSegue(withIdentifier: self.tabBarControllerSegueId, sender: nil)
        }) { (error: Error) -> () in
            print(error)
        }
    }

}
