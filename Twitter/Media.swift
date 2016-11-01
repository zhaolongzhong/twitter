//
//  Media.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/30/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import RealmSwift

class Media: Object {
    static let TAG = NSStringFromClass(Media.self)

    dynamic var id: String!
    dynamic var mediaUrl: String!
    dynamic var url: String!
    dynamic var type: String!
    dynamic var tweetId: String!
    dynamic var videoUrl: String?

    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(dictionary: NSDictionary, tweetId: String) throws {
        self.id = String(describing: dictionary["id"]!)
        self.mediaUrl = dictionary["media_url_https"] as! String
        self.url = dictionary["url"] as! String
        self.type = dictionary["type"] as! String
        self.tweetId = tweetId
    }
    
    static func mapFrom(array: [NSDictionary], tweetId: String) -> [Media] {
        let realm = AppDelegate.getInstance().realm!
        
        for dictionary in array {
            let media = Media()
            
            do {
                try media.mapFrom(dictionary: dictionary, tweetId: tweetId)
                realm.beginWrite()
                realm.add(media, update: true)
                try realm.commitWrite()
            } catch let error {
                print(error)
                realm.cancelWrite()
            }
        }
        
        return Array(Media.getMediaByTweetId(tweetId: tweetId))
    }
    
    static func getMediaById(id: String) -> Media? {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(Media.self).filter("id == %@", id).first
    }
    
    static func getMediaByTweetId(tweetId: String) -> [Media] {
        let realm = AppDelegate.getInstance().realm!
        return Array(realm.objects(Media.self).filter("tweetId == %@", tweetId))
    }
}
