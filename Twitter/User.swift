//
//  User.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/29/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import RealmSwift

class User: Object {
    static let TAG = NSStringFromClass(User.self)

    dynamic var id: String!
    dynamic var name: String!
    dynamic var screenName: String!
    dynamic var defaultProfile: Bool = false
    dynamic var profile: String!
    dynamic var profileBackgroundColor: String?
    dynamic var profileBackgroundImageUrl: String?
    dynamic var profileBannerUrl: String?
    dynamic var profileImageUrl: String?
    dynamic var profileUseBackgroundImage: Bool = true
    dynamic var statusesCount: Int = 0
    dynamic var favoriteCount: Int = 0
    dynamic var followRequestSent: Bool = false
    dynamic var followersCount: Int = 0
    dynamic var following: Bool = true
    dynamic var friendsCount: Int = 0
    dynamic var notifications: Bool = false
    dynamic var isDefault: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(dictionary: NSDictionary) throws {
        self.id  = String(describing: dictionary["id"]!)
        self.name = dictionary["name"] as! String
        self.screenName = dictionary["screen_name"] as! String
        self.defaultProfile = dictionary["default_profile"] as! Bool
        self.profile = dictionary["description"] as! String
        self.profileBackgroundColor = String(describing: dictionary["profile_background_color"])
        self.profileBackgroundImageUrl = dictionary["profile_background_image_url_https"] as? String
        self.profileBannerUrl = dictionary["profile_banner_url"] as? String
        self.profileImageUrl = dictionary["profile_image_url_https"] as? String
        self.profileUseBackgroundImage = dictionary["profile_use_background_image"] as! Bool
        self.statusesCount = dictionary["statuses_count"] as! Int
        if let favoriteCount = dictionary["favorite_count"] as? Int {
            self.favoriteCount = favoriteCount
        }
        self.followRequestSent = dictionary["follow_request_sent"] as! Bool
        self.followersCount = dictionary["followers_count"] as! Int
        self.following = dictionary ["following"] as! Bool
        self.friendsCount = dictionary["friends_count"] as! Int
        self.notifications = dictionary["notifications"] as! Bool
    }
    
    static func getDefaultUser() -> User? {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(User.self).filter("isDefault == %@", true).first
    }
}
