//
//  Tweet.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/28/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import RealmSwift

class Tweet: Object {
    static let TAG = NSStringFromClass(Tweet.self)
    
    static let homeTimeline = "HomeTimeline"
    static let mentionsTimeline = "MentionsTimeline"
    static let userTimeline = "UserTimeline"
    
    dynamic var id: String = ""
    dynamic var text: String = ""
    dynamic var createdAt: Date!
    dynamic var favorited: Bool = false
    dynamic var retweeted: Bool = false
    dynamic var favoriteCount: Int = 0
    dynamic var retweetCount:Int = 0
    dynamic var screenName = ""
    
    dynamic var user: User?
    dynamic var media: Media?
    dynamic var type: String = Tweet.homeTimeline
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(dictionary: NSDictionary) throws {
        self.id = String(describing: dictionary["id"]!)
        self.text = dictionary["text"] as! String
        let datetimeString = dictionary["created_at"] as! String
        let dateFormatter = DateFormatter()
        // Example:  "created_at" = "Sun Oct 30 03:33:43 +0000 2016"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZZZ yyyy"
        self.createdAt = dateFormatter.date(from: datetimeString)
        self.favorited = dictionary["favorited"] as! Bool
        self.retweeted = dictionary["retweeted"] as! Bool
        self.favoriteCount = dictionary["favorite_count"] as! Int
        self.retweetCount = dictionary["retweet_count"] as! Int

        self.user = User()
        try self.user!.mapFrom(dictionary: dictionary["user"] as! NSDictionary)
        
        if let entities = dictionary["entities"] as? NSDictionary {
            if let medias = entities["media"] as? [NSDictionary] {
                let medias = Media.mapFrom(array: medias, tweetId: self.id)
                self.media = medias.first
            }
        } else {
            print("entities is not NSDictionary or is nil.")
        }
    }
    
    static func mapFrom(array: [NSDictionary], type: String) -> [Tweet] {
        let realm = AppDelegate.getInstance().realm!
        var tweets:[Tweet] = []
        print("array count: \(array.count)")
//        print(array.first)
//        print(array.last)
        
        for dictionary in array {
            let tweet = Tweet()
            
            do {
                try tweet.mapFrom(dictionary: dictionary)
                tweet.type = type
                
//                if type != Tweet.userTimeline {
                    realm.beginWrite()
                    realm.add(tweet, update: true)
                    try realm.commitWrite()
//                }
                
                tweets.append(tweet)
            } catch let error {
                print(error)
                realm.cancelWrite()
            }
        }
        
//        return Tweet.getTweetsByType(type: type)
        return tweets;
    }
    
    static func getAllTweets() -> [Tweet] {
        let realm = AppDelegate.getInstance().realm!
        return Array(realm.objects(Tweet.self).sorted(byProperty: "createdAt", ascending: false))
    }
    
    static func getTweetsByType(type: String) -> [Tweet]{
        let realm = AppDelegate.getInstance().realm!
        return Array(realm.objects(Tweet.self).filter("type == %@", type).sorted(byProperty: "createdAt", ascending: false))
    }
    
    static func getTweetsByType(type: String, screenName: String) -> [Tweet]{
        let realm = AppDelegate.getInstance().realm!
        return Array(realm.objects(Tweet.self).filter("type == %@ AND screenName", type, screenName).sorted(byProperty: "createdAt", ascending: false))
    }
    
    static func getTweetById(id: String) -> Tweet? {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(Tweet.self).filter("id == %@", id).first
    }
}
