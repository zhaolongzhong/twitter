//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/31/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import Kingfisher

class TweetDetailViewController: UIViewController {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screenNameLabel: UILabel!
    @IBOutlet var tweetTextLabel: UILabel!
    @IBOutlet var mediaImageView: UIImageView!
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var mediaImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var retweetCountLabel: UILabel!
    @IBOutlet var retweetLabel: UILabel!
    
    @IBOutlet var favoriteCountLabel: UILabel!
    @IBOutlet var favoriteLabel: UILabel!

    @IBOutlet var countView: UIView!
    @IBOutlet var retweetCountView: UIView!
    @IBOutlet var favoriteCountView: UIView!
    
    @IBOutlet var retweetImageView: UIImageView!
    @IBOutlet var favoriteImageView: UIImageView!
    
    @IBOutlet var replyView: UIView!
    @IBOutlet var retweetView: UIView!
    @IBOutlet var favoriteView: UIView!
    @IBOutlet var messageView: UIView!
    
    var tweet: Tweet!
    var twitterClient: TwitterClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.twitterClient = TwitterClient.getInstance()
        
        self.profileImageView.layer.cornerRadius = 4
        self.profileImageView.layer.masksToBounds = true
        self.mediaImageView.layer.cornerRadius = 4
        self.mediaImageView.layer.masksToBounds = true
        
        self.replyView.isUserInteractionEnabled = true
        let replyViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailViewController.replyViewTapped))
        self.replyView.addGestureRecognizer(replyViewRecognizer)
        
        self.retweetView.isUserInteractionEnabled = true
        let retweetViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailViewController.retweetViewTapped))
        self.retweetView.addGestureRecognizer(retweetViewRecognizer)
        
        self.favoriteView.isUserInteractionEnabled = true
        let favoriteViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailViewController.favoriteViewTapped))
        self.favoriteView.addGestureRecognizer(favoriteViewRecognizer)
        
        self.messageView.isUserInteractionEnabled = true
        let messageViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailViewController.messageViewTapped))
        self.messageView.addGestureRecognizer(messageViewRecognizer)

        

        let user = self.tweet.user!
        self.nameLabel.text = user.name
        self.screenNameLabel.text = "@\(user.screenName!)"
        self.tweetTextLabel.text = self.tweet.text
        self.tweetTextLabel.sizeToFit()
        if self.tweet.retweetCount > 0 {
            self.retweetCountLabel.text = "\(self.tweet.retweetCount)"
            self.retweetCountLabel.sizeToFit()
        } else {
            self.retweetCountView.widthAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        self.retweetImageView.image = UIImage(named: self.tweet.retweeted ? "retweet_green" : "retweet")
        self.favoriteImageView.image = UIImage(named: self.tweet.favorited ? "like_red" : "like")
        
        if self.tweet.favoriteCount > 0 {
            self.favoriteCountLabel.text = "\(self.tweet.favoriteCount)"
            self.favoriteCountLabel.sizeToFit()
        } else {
            self.favoriteCountView.widthAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        if self.tweet.retweetCount == 0 && self.tweet.favoriteCount == 0 {
            self.countView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        
        let dateFormatter = DateFormatter()
        // Example:  "created_at" = "Sun Oct 30 03:33:43 +0000 2016"
//        dateFormatter.dateFormat = "EEE MMM dd HH:mm: ZZZZZ yyyy"
        dateFormatter.dateFormat = "MM/dd/yy hh:mm"
        self.createdAtLabel.text = dateFormatter.string(from: self.tweet.createdAt)
        
        self.profileImageView.kf.indicatorType = .activity
        if let imageURL = user.profileImageUrl {
            let url = URL(string: imageURL)!
            let resource = ImageResource(downloadURL: url, cacheKey: "\(imageURL)")
            self.profileImageView.kf.setImage(with: resource, placeholder: UIImage(named:"placeholder"), options: [.transition(.fade(0.2))])
        }
        
        self.mediaImageViewHeightConstraint.constant = 0
        if let media = self.tweet.media {
            if media.type == "photo" {
                self.mediaImageView.kf.indicatorType = .activity
                
                let url = URL(string: media.mediaUrl)!
                print("photo media: \(url)")
                let resource = ImageResource(downloadURL: url, cacheKey: "\(media.mediaUrl)")
                
                self.mediaImageView.kf.indicatorType = .activity
                self.mediaImageView.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))])
                self.mediaImageViewHeightConstraint.constant = 300
            }
        }
    }

    func replyViewTapped() {
        // todo: implement
        print("reply clicked")
    }
    
    func retweetViewTapped() {
        print("retweet clicked")
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let retweetActionSheet = UIAlertAction(title: "Retweet", style: .default, handler: { (action) -> Void in
            // todo: implement
            self.retweetImageView.image = UIImage(named: !self.tweet.retweeted ? "retweet_green" : "retweet")
            
            self.twitterClient.retweet(tweetId: self.tweet.id, success: { (dictionary: NSDictionary) -> () in
                print(dictionary)
            }) { (error: Error) -> () in
                print(error)
            }
        })
        
        let quoteTweetActionSheet = UIAlertAction(title: "Quote Tweet", style: .default, handler: { (action) -> Void in
            // todo: implement
        })
        
        alertController.addAction(retweetActionSheet)
        alertController.addAction(quoteTweetActionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    func favoriteViewTapped() {
        print("favorite clicked")
        
        self.favoriteImageView.image = UIImage(named: !self.tweet.favorited ? "like_red" : "like")
        
        if !self.tweet.favorited {
            // todo: implement
        }
        
        self.twitterClient.favorite(tweetId: self.tweet.id, favorited: !self.tweet.favorited, success: { (dictionary: NSDictionary) -> () in
            print(dictionary)
        }) { (error: Error) -> () in
            print(error)
        }
    }

    func messageViewTapped() {
        // todo: implement
        print("message clicked")
    }

}
