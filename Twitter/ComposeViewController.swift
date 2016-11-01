//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/31/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var tweetTextField: UITextField!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var tweetButton: UIButton!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var bottomViewBottomConstraint: NSLayoutConstraint!
    
    var twitterClient: TwitterClient!
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.twitterClient = TwitterClient.getInstance()
        
        // Do any additional setup after loading the view.
        if let tweet = self.tweet {
            let user = tweet.user!
            self.tweetTextField.text = "@\(user.screenName!) "
        }
        
        tweetTextField.becomeFirstResponder()
        tweetTextField.addTarget(self, action: #selector(ComposeViewController.textFieldDidChange), for: .editingChanged)
        
        bottomViewBottomConstraint.constant = 250
        
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tweetButton.layer.borderWidth = 1
        tweetButton.layer.borderColor = UIColor.lightGray.cgColor
        tweetButton.layer.cornerRadius = 4
        tweetButton.setTitleColor(.white, for: .highlighted)
    }
    
    func textFieldDidChange() {
        let hasCharacters: Bool = (tweetTextField.text?.characters.count)! > 0
        let lightBlue = UIColor(red: 42/255.0, green: 163/255.0, blue: 239/255.0, alpha: 1.0)
        
        self.tweetButton.isEnabled = hasCharacters
        self.tweetButton.backgroundColor = hasCharacters ? lightBlue : UIColor.clear
        self.tweetButton.setTitleColor(hasCharacters ? UIColor.white : UIColor.lightGray, for: .normal)
        self.tweetButton.layer.borderColor = hasCharacters ? lightBlue.cgColor : UIColor.lightGray.cgColor
        self.countLabel.text = String(describing: (140 - (self.tweetTextField!.text?.characters.count)!))
    }

    @IBAction func tweetButtonAction(_ sender: AnyObject) {
        if tweetTextField.text!.characters.count > 0 && tweetTextField.text!.characters.count <= 140 {
            postTweet(tweetId: self.tweet?.id)
        } else {
            //todo: handle error
        }
    }
    
    @IBAction func closeButtonAction(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func postTweet(tweetId: String?) {
        let tweetText = self.tweetTextField.text!
        self.twitterClient.postTweet(tweetText: tweetText, tweetId: tweetId, success: { (dictionary: NSDictionary) -> () in
            let tweet = Tweet()
            
            do {
                try tweet.mapFrom(dictionary: dictionary)
                let realm = AppDelegate.getInstance().realm!
                try! realm.write {
                    realm.add(tweet, update: true)
                }
                
                self.dismiss(animated: true, completion: nil)
            } catch let error {
                print(error)
            }
            
        }) { (error: Error) -> () in
            print(error)
            
        }
    }
    
}
