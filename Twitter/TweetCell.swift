//
//  TweetCell.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/31/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import Kingfisher

protocol TweetCellDelegate: class {
    func tweetCell(tweetCell: TweetCell, replyDidClick: Bool)
    func tweetCell(tweetCell: TweetCell, retweetDidClick retweet: Bool)
    func tweetCell(tweetCell: TweetCell, favoriteDidClick favorited: Bool)
    func tweetCell(tweetCell: TweetCell, messageDidClick: Bool)
}

class TweetCell: UITableViewCell {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screenNameLabel: UILabel!
    @IBOutlet var tweetTextLabel: UILabel!
    @IBOutlet var mediaImageView: UIImageView!
    @IBOutlet var mediaImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var seperatorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var favoriteImageView: UIImageView!
    @IBOutlet var favoriteCountLabel: UILabel!
    @IBOutlet var retweetImageView: UIImageView!
    @IBOutlet var retweetCountLabel: UILabel!
    @IBOutlet var replyView: UIView!
    @IBOutlet var retweetView: UIView!
    @IBOutlet var favoriteView: UIView!
    @IBOutlet var messageView: UIView!
    
    weak var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            let user = self.tweet.user!
            self.nameLabel.text = user.name
            self.screenNameLabel.text = "@\(user.screenName!)"
            self.screenNameLabel.sizeToFit()
            self.tweetTextLabel.text = self.tweet.text
            self.tweetTextLabel.sizeToFit()
            self.createdAtLabel.text = relativePast(for: self.tweet.createdAt)
            
            self.favoriteCountLabel.isHidden = self.tweet.favoriteCount <= 0
            self.favoriteCountLabel.text = String(self.tweet.favoriteCount)
            
            self.retweetCountLabel.isHidden = self.tweet.retweetCount <= 0
            self.retweetCountLabel.text = String(self.tweet.retweetCount)
            
            self.retweetImageView.image = UIImage(named: self.tweet.retweeted ? "retweet_green" : "retweet")
            self.favoriteImageView.image = UIImage(named: self.tweet.favorited ? "like_red" : "like")
            
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
                    self.mediaImageViewHeightConstraint.constant = 130
                }
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initViews()
    }
    
    func initViews() {
        layoutMargins = .zero
//        selectedBackgroundView = UIView(frame: frame)
//        selectedBackgroundView?.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.seperatorHeightConstraint.constant = 0.5
        self.profileImageView.layer.cornerRadius = 4
        self.profileImageView.layer.masksToBounds = true
        self.mediaImageView.layer.cornerRadius = 4
        self.mediaImageView.layer.masksToBounds = true
        
        self.replyView.isUserInteractionEnabled = true
        let replyViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetCell.replyViewTapped))
        self.replyView.addGestureRecognizer(replyViewRecognizer)
        
        self.retweetView.isUserInteractionEnabled = true
        let retweetViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetCell.retweetViewTapped))
        self.retweetView.addGestureRecognizer(retweetViewRecognizer)
        
        self.favoriteView.isUserInteractionEnabled = true
        let favoriteViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetCell.favoriteViewTapped))
        self.favoriteView.addGestureRecognizer(favoriteViewRecognizer)
        
        self.messageView.isUserInteractionEnabled = true
        let messageViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetCell.messageViewTapped))
        self.messageView.addGestureRecognizer(messageViewRecognizer)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func replyViewTapped() {
        // todo: implement
        print("reply clicked")
        
        self.delegate?.tweetCell(tweetCell: self, replyDidClick: true)
    }
    
    func retweetViewTapped() {
        // todo: implement
        print("retweet clicked")

        self.retweetImageView.image = UIImage(named: !self.tweet.retweeted ? "retweet_green" : "retweet")
        let flag: Int = self.tweet.retweeted ? -1 : 1
        let count = self.tweet.retweetCount + flag
        self.retweetCountLabel.text = "\(count)"
        self.retweetCountLabel.isHidden = count == 0
        self.delegate?.tweetCell(tweetCell: self, retweetDidClick: !self.tweet.retweeted)
        
//        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
//        let retweetActionSheet = UIAlertAction(title: "Retweet", style: .default, handler: { (action) -> Void in
//            // todo: implement
//           
//        })
//        
//        let quoteTweetActionSheet = UIAlertAction(title: "Quote Tweet", style: .default, handler: { (action) -> Void in
//            // todo: implement
//        })
//        
//        alertController.addAction(retweetActionSheet)
//        alertController.addAction(quoteTweetActionSheet)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func favoriteViewTapped() {
        // todo: implement
        print("favorite clicked")
        self.favoriteImageView.image = UIImage(named: !self.tweet.favorited ? "like_red" : "like")
        let flag: Int = self.tweet.favorited ? -1 : 1
        let count = self.tweet.favoriteCount + flag
        self.favoriteCountLabel.text = "\(count)"
        self.favoriteCountLabel.isHidden = count == 0
        self.delegate?.tweetCell(tweetCell: self, favoriteDidClick: !self.tweet.favorited)
    }
    
    func messageViewTapped() {
        // todo: implement
        print("message clicked")
        self.delegate?.tweetCell(tweetCell: self, messageDidClick: true)
    }
    
    func relativePast(for date : Date) -> String {
        
        let units = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .weekOfYear])
        let components = Calendar.current.dateComponents(units, from: date, to: Date())
        
        if components.year! > 0 {
            return "\(components.year!)y"
            
        } else if components.month! > 0 {
            return "\(components.month!)m"
            
        } else if components.weekOfYear! > 0 {
            return "\(components.weekOfYear!)w"
            
        } else if (components.day! > 0) {
            return "\(components.day!)d"
            
        } else if components.hour! > 0 {
            return "\(components.hour!)h"
            
        } else if components.minute! > 0 {
            return "\(components.minute!)m"
            
        } else {
            return "\(components.second!)s"
        }
    }

}

