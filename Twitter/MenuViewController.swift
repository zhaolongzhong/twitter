//
//  MenuViewController.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 11/5/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import Kingfisher

protocol MenuViewControllerDelegate: class {
    func menuViewController(menuViewController: MenuViewController, didSelectAt index:Int)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screenNameLabel: UILabel!
    
    var twitterClient: TwitterClient!
    let menus: [String] = ["Home", "Mentions", "Profile"]
    var menuItems: [String] = []
    var user: User!
    
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.twitterClient = TwitterClient.getInstance()
        
        self.user = User.getDefaultUser()
        
        if self.user == nil {
            verifyCredentials()
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        invalidateViews()
    }
    
    func invalidateViews() {
        if self.user == nil {
            return
        }
     
        self.nameLabel.text = self.user.name
        self.screenNameLabel.text = "@\(self.user.screenName!)"
        
        self.profileImageView.kf.indicatorType = .activity
        if let imageURL = user.profileImageUrl {
            let url = URL(string: imageURL)!
            let resource = ImageResource(downloadURL: url, cacheKey: "\(imageURL)")
            self.profileImageView.kf.setImage(with: resource, placeholder: UIImage(named:"placeholder"), options: [.transition(.fade(0.2))])
            self.profileImageView.layer.cornerRadius = 4
            self.profileImageView.layer.borderColor = UIColor.white.cgColor
            self.profileImageView.layer.borderWidth = 2
            self.profileImageView.layer.masksToBounds = true
        }
        
        if let profileBannerUrl = user.profileBannerUrl {
            let url = URL(string: profileBannerUrl)!
            let resource = ImageResource(downloadURL: url)
            self.backgroundImageView.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))])
            self.backgroundImageView.contentMode = .scaleAspectFill
            self.backgroundImageView.clipsToBounds = true
            self.backgroundImageView.layer.masksToBounds = true
        }

    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let menuTitle = self.menus[indexPath.row]
        cell.textLabel?.text = menuTitle
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.menuViewController(menuViewController: self, didSelectAt: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func verifyCredentials() {
        self.twitterClient.verifyCredentials(success: { (user: User) -> () in
            print(user)
            self.user = User.getDefaultUser()
            self.invalidateViews()
        }) { (error: Error) -> () in
            print(error)
        }
    }
}
