//
//  MainViewController.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/28/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetCellDelegate {
   
    @IBOutlet var tableView: UITableView!

    let composeViewControllerSegue = "ComposeViewControllerSegue"
    let tweetDetailViewControllerSegue = "TweetDetailViewControllerSegue"
    let profileViewControllerSegue = "ProfileViewControllerSegue"
    let tweetCell = "TweetCell"
    
    var type: String! {
        didSet {
            self.tweets = Tweet.getTweetsByType(type: self.type)
        }
    }
    var twitterClient: TwitterClient!
    var refreshControl: UIRefreshControl!
    var loadingMoreView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var tweets: [Tweet]? {
        didSet {
            self.invalidateViews()
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView?.stopAnimating()
        }
    }
    
    var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.twitterClient = TwitterClient.getInstance()
        
//        let lightBlue = UIColor(red: 42/255.0, green: 163/255.0, blue: 239/255.0, alpha: 1.0)
//        self.navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64))
//        self.navBar.tintColor = lightBlue
//        self.view.addSubview(navBar);
//        let navItem = UINavigationItem(title: "Twitter")
//        let follow = UIBarButtonItem(image: UIImage(named:"follow"), style: .plain, target: nil, action: nil)
//        let compose = UIBarButtonItem(image: UIImage(named: "compose"), style: .plain, target: nil, action: nil)
//        let search = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: nil, action: nil)
//        
//        navItem.leftBarButtonItem = follow
//        navItem.rightBarButtonItems = [compose, search]
//        let titleImageView = UIImageView(image: UIImage(named: "logo_blue"))
//        titleImageView.isUserInteractionEnabled = true
//        let recognizer = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.titleImageViewTapped))
//        titleImageView.addGestureRecognizer(recognizer)
//        navItem.titleView = titleImageView
//        
//        navItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 8, 0, 40)
//        navItem.rightBarButtonItems?.first?.imageInsets = UIEdgeInsetsMake(0, -32, 0, -8)
//        self.navBar.setItems([navItem], animated: false);
        
        let titleImageView = UIImageView(image: UIImage(named: "logo_blue"))
        titleImageView.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.titleImageViewTapped))
        titleImageView.addGestureRecognizer(recognizer)
        self.navigationItem.titleView = titleImageView

        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, -8, 0, 8)
        self.navigationItem.rightBarButtonItems?.first?.imageInsets = UIEdgeInsetsMake(0, -16, 0, 8)
        
        // Set up table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: self.tweetCell, bundle: nil), forCellReuseIdentifier: self.tweetCell)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        self.tableView.keyboardDismissMode = .onDrag
//        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 64).isActive = true
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        self.loadingMoreView = InfiniteScrollActivityView(frame: frame)
        self.loadingMoreView!.isHidden = true
        self.tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        self.tableView.insertSubview(refreshControl, at: 1)
        
//        reloadTimeline()
        self.tweets = Tweet.getTweetsByType(type: self.type)
    }

    func invalidateViews() {
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        reloadTimeline()
    }
    
    func titleImageViewTapped() {
        self.tableView.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
    }
    
    @IBAction func composeBarButtonAction(_ sender: AnyObject) {
        performSegue(withIdentifier: self.composeViewControllerSegue, sender: self)
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.type == Tweet.homeTimeline ? refreshHomeTimeline() : refreshMentionsTimeline()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tweetDetailViewController = segue.destination as? TweetDetailViewController {
            
            if let tableView = sender as? UITableView {
                tweetDetailViewController.tweet = self.tweets![tableView.indexPathForSelectedRow!.row]
            }
        }
        
        if let composeViewController = segue.destination as? ComposeViewController {
            if let tweetCell = sender as? TweetCell {
                composeViewController.tweet = tweetCell.tweet
            }
        }
        
        if let profileViewController = segue.destination as? ProfileViewController {
            if let tweetCell = sender as? TweetCell {
                profileViewController.user = tweetCell.tweet.user
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.tweetCell, for: indexPath) as! TweetCell
        
        let tweet = self.tweets?[indexPath.row]
        cell.tweet = tweet
        cell.delegate = self
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: self.tweetDetailViewControllerSegue, sender: tableView)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - TweetCellDelegate
    func tweetCell(tweetCell: TweetCell, profileDidClick user: User) {
        performSegue(withIdentifier: self.profileViewControllerSegue, sender: tweetCell)
    }
    
    func tweetCell(tweetCell: TweetCell, replyDidClick: Bool) {
        performSegue(withIdentifier: self.composeViewControllerSegue, sender: tweetCell)
    }
    
    func tweetCell(tweetCell: TweetCell, retweetDidClick retweet: Bool) {
        //todo:
        self.twitterClient.retweet(tweetId: tweetCell.tweet.id, success: { (dictionary: NSDictionary) -> () in
            print(dictionary)
            self.reloadTimeline()
        }) { (error: Error) -> () in
            print(error)
            
        }
    }
    
    func tweetCell(tweetCell: TweetCell, favoriteDidClick favorited: Bool) {
        //todo: 
        self.twitterClient.favorite(tweetId: tweetCell.tweet.id, favorited: favorited, success: { (dictionary: NSDictionary) -> () in
            print(dictionary)
            self.reloadTimeline()
        }) { (error: Error) -> () in
            print(error)
        }
    }
    
    func tweetCell(tweetCell: TweetCell, messageDidClick: Bool) {
        //todo:
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (!isMoreDataLoading) {
//            // Calculate the position of one screen length before the bottom of the results
//            let scrollViewContentHeight = tableView.contentSize.height
//            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
//            
//            // When the user has scrolled past the threshold, start requesting
//            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
//                isMoreDataLoading = true
//                
//                // Update position of loadingMoreView, and start loading indicator
//                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
//                loadingMoreView?.frame = frame
//                loadingMoreView!.startAnimating()
//                
//                // Load more results
//
//            }
//        }
//    }
    
    func reloadTimeline() {
        switch self.type {
        case Tweet.homeTimeline:
            loadHomeTimeline()
            break
        case Tweet.mentionsTimeline:
            loadMentionsTimeline()
            break
        default:
            break
        }
    }
    
    func loadHomeTimeline() {
        print("loadHomeTimeline")
        self.twitterClient.homeTimeline(success: { (tweets: [Tweet]) -> () in
            print("homeTimeline count: \(tweets.count)")
            self.tweets = tweets.sorted{ $0.0.createdAt > $0.1.createdAt }
        }) { (error: Error) -> () in
            print(error)
        }
    }
    
    func loadMentionsTimeline() {
        print("loadMentionsTimeline")
        self.twitterClient.mentionsTimeline(success: { (tweets: [Tweet]) -> () in
            print("mentionsTimeline count: \(tweets.count)")
            self.tweets = tweets.sorted{ $0.0.createdAt > $0.1.createdAt }
        }) { (error: Error) -> () in
            print(error)
        }
    }
    
    func refreshHomeTimeline() {
        self.twitterClient.homeTimeline(success: { (tweets: [Tweet]) -> () in
            print("Home: \(tweets.count)")
            self.tweets = tweets
            self.refreshControl.endRefreshing()
        }) { (error: Error) -> () in
            print(error)
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshMentionsTimeline() {
        self.twitterClient.mentionsTimeline(success: { (tweets: [Tweet]) -> () in
            print("Metions: \(tweets.count)")
            self.tweets = tweets
            self.refreshControl.endRefreshing()
        }) { (error: Error) -> () in
            print(error)
            self.refreshControl.endRefreshing()
        }

    }
    
}
