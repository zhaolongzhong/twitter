//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 11/5/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.

//  Reference: https://github.com/deanbrindley87/Twitter-UI
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, TweetCellDelegate {

    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let distance_W_LabelHeader:CGFloat = 30.0 // The distance between the top of the screen and the top of the White Label
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerLabel: UILabel!

    @IBOutlet var tweetsCountLabel: UILabel!
    @IBOutlet var followerCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screenNameLabel: UILabel!
    @IBOutlet var profileView: UIView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedView: UIView!
    
    var headerBlurImageView: UIImageView!
    var headerImageView: UIImageView!
    var user: User?
    
    
    let tweetDetailViewControllerSegue = "TweetDetailViewControllerSegue"
    let tweetCell = "TweetCell"
    
    var twitterClient: TwitterClient!
    var refreshControl: UIRefreshControl!
    var loadingMoreView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var isFromLeftBar = false
    var tweets: [Tweet] = [] {
        didSet {
            self.invalidateViews()
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView?.stopAnimating()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.twitterClient = TwitterClient.getInstance()
        
        if self.user == nil {
            self.user = User.getDefaultUser()
        }

        self.closeButton.isHidden = self.isFromLeftBar
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: self.tweetCell, bundle: nil), forCellReuseIdentifier: self.tweetCell)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        self.tableView.keyboardDismissMode = .onDrag
        
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 106)
        self.tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
        
//        self.tweets = Tweet.getTweetsByType(type: Tweet.userTimeline, screenName: self.user!.screenName)
        print(self.user)
        loadUserTimeline()
    }

    
    func invalidateViews() {
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Header - Image
        headerImageView = UIImageView(frame: headerView.bounds)
        headerBlurImageView = UIImageView(frame: headerView.bounds)
//        headerImageView?.image = UIImage(named: "header_image")
//        headerBlurImageView?.image = UIImage(named: "header_image")?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
        if self.user!.profileBannerUrl != nil {
            let imageUrl = self.user!.profileBannerUrl!
            headerImageView.kf.setImage(with: URL(string: imageUrl)!)
            
            headerBlurImageView.kf.setImage(with: URL(string: imageUrl)!, completionHandler: {
                (image, error, cacheType, imageUrl) in
                // image: Image? `nil` means failed
                // error: NSError? non-`nil` means failed
                // cacheType: CacheType
                //                  .none - Just downloaded
                //                  .memory - Got from memory cache
                //                  .disk - Got from memory Disk
                // imageUrl: URL of the image
                self.headerBlurImageView?.image = image?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
            })
        } else {
            let imageUrl = self.user!.profileBackgroundImageUrl!
            headerImageView.kf.setImage(with: URL(string: imageUrl)!)
            
            headerBlurImageView.kf.setImage(with: URL(string: imageUrl)!, completionHandler: {
                (image, error, cacheType, imageUrl) in
                // image: Image? `nil` means failed
                // error: NSError? non-`nil` means failed
                // cacheType: CacheType
                //                  .none - Just downloaded
                //                  .memory - Got from memory cache
                //                  .disk - Got from memory Disk
                // imageUrl: URL of the image
                self.headerBlurImageView?.image = image?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
            })
        }
        
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerView.insertSubview(headerImageView, belowSubview: headerLabel)
        
        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView?.alpha = 0.0
        headerView.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        headerView.bringSubview(toFront: tweetsCountLabel)
        
        headerView.clipsToBounds = true
        
        self.avatarImageView.kf.setImage(with: URL(string: self.user!.profileImageUrl!))
        self.avatarImageView.layer.cornerRadius = 4
        self.avatarImageView.layer.borderColor = UIColor.white.cgColor
        self.avatarImageView.layer.borderWidth = 3
        self.avatarImageView.layer.masksToBounds = true
        self.headerLabel.text = self.user!.name
        self.nameLabel.text = self.user!.name
        self.screenNameLabel.text = "@\(self.user!.screenName!)"
        
        var friends = ""
        let friendsCount = self.user!.friendsCount
        if (self.user!.followersCount > 1000000) {
            let m = Int(friendsCount/1000000)
            let decimal = Int((friendsCount%1000000)/100000)
            friends = "\(m).\(decimal) m"
        } else if friendsCount > 1000 {
            friends = "\(friendsCount/1000) k"
            let k = Int(friendsCount/1000)
            let decimal = Int((friendsCount%1000)/100)
            friends = "\(k).\(decimal) k"
        }
        
        self.followerCountLabel.text = getFriendlyCount(count: self.user!.followersCount)
        
        self.followingCountLabel.text = getFriendlyCount(count: self.user!.friendsCount)
        
        // todo: fix start state issue
        self.tableView.scrollsToTop = true
        self.tableView.setContentOffset(CGPoint(x: 0, y: -headerView.frame.size.height), animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.tweetCell, for: indexPath) as! TweetCell
        
        let tweet = self.tweets[indexPath.row]
        cell.tweet = tweet
        cell.delegate = self
        
        return cell

    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + headerView.bounds.height
        
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // Pull down
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            // Hide views if scrolled super fast
            headerView.layer.zPosition = 0
            headerLabel.isHidden = true
            tweetsCountLabel.isHidden = true
        } else {
        // Scroll up/down
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            headerLabel.isHidden = false
            tweetsCountLabel.isHidden = false
            let alignToNameLabel = -offset + nameLabel.frame.origin.y + headerView.frame.height + offset_HeaderStop
            
            headerLabel.frame.origin = CGPoint(x: headerLabel.frame.origin.x, y: max(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop))
            tweetsCountLabel.frame.origin = CGPoint(x: tweetsCountLabel.frame.origin.x, y: max(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop) + 18)
            
            headerBlurImageView?.alpha = min (1.0, (offset - alignToNameLabel)/distance_W_LabelHeader)
            
            
            // Avatar
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImageView.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImageView.bounds.height * (1.0 + avatarScaleFactor)) - avatarImageView.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                if avatarImageView.layer.zPosition < headerView.layer.zPosition{
                    headerView.layer.zPosition = 0
                }
            } else {
                if avatarImageView.layer.zPosition >= headerView.layer.zPosition{
                    headerView.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        headerView.layer.transform = headerTransform
        avatarImageView.layer.transform = avatarTransform
        
        // Apply Transformations
        headerView.layer.transform = headerTransform
        avatarImageView.layer.transform = avatarTransform
        
        // Segment control
        
        let segmentViewOffset = profileView.frame.height - segmentedView.frame.height - offset
        var segmentTransform = CATransform3DIdentity
        
        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offset_HeaderStop), 0)
        segmentedView.layer.transform = segmentTransform
        // Set scroll view insets just underneath the segment control
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.frame.maxY, 0, 0, 0)
    }
    
    // MARK: - TweetCellDelegate
    func tweetCell(tweetCell: TweetCell, profileDidClick user: User) {
        //todo: implement
    }

    func tweetCell(tweetCell: TweetCell, replyDidClick: Bool) {
        //todo: implement
    }

    func tweetCell(tweetCell: TweetCell, retweetDidClick retweet: Bool) {
        //todo: implement
    }

    func tweetCell(tweetCell: TweetCell, favoriteDidClick favorited: Bool) {
        //todo: implement
    }
    
    func tweetCell(tweetCell: TweetCell, messageDidClick: Bool) {
        //todo: implement
    }
    
    @IBAction func closeButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadUserTimeline() {
        print("loadMentionsTimeline")
        self.twitterClient.userTimeline(screenName: self.user!.screenName, success: { (tweets: [Tweet]) -> () in
            print("userTimeline count: \(tweets.count)")
            self.tweets = tweets.sorted{ $0.0.createdAt > $0.1.createdAt }
        }) { (error: Error) -> () in
            print(error)
        }
    }
    
    func refreshUserTimeline() {
        self.twitterClient.userTimeline(screenName: self.user!.screenName, success: { (tweets: [Tweet]) -> () in
            print("refresh userTimeline count: \(tweets.count)")
            self.tweets = tweets
            self.refreshControl.endRefreshing()
        }) { (error: Error) -> () in
            print(error)
            self.refreshControl.endRefreshing()
        }
        
    }
    
    func getFriendlyCount(count: Int) -> String {
        var friends = ""
        
        if (self.user!.followersCount > 1000000) {
            let m = Int(count/1000000)
            let decimal = Int((count%1000000)/100000)
            friends = "\(m).\(decimal) m"
        } else if count > 1000 {
            friends = "\(count/1000) k"
            let k = Int(count/1000)
            let decimal = Int((count%1000)/100)
            friends = "\(k).\(decimal) k"
        } else {
            friends = "\(count)"
        }

        return friends
    }
}
