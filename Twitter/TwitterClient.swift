//
//  TwitterClient.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/28/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//


import UIKit
import OAuthSwift

class TwitterClient: OAuthSwiftClient {
    
    static let oauthTokenKey = "oathToken"
    static let oauthTokenSecretKey = "oauthTokenSecret"
    static let consumerKey = "xmnbz8aV49rka1EsbaLPphqTS"
    static let consumerSecret = "IUKtVsuOHAoCspH8teZzcp2MXTYK3DMZO13FX7JRFbU1fvih3I"
    
    let baseUrl = "https://api.twitter.com/1.1/"
    let homeTimelineUrl = "statuses/home_timeline.json"
    let credentialUrl = "account/verify_credentials.json"
    let userTimelineUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    
    static let oauthSwift = OAuth1Swift (
        consumerKey: TwitterClient.consumerKey,
        consumerSecret: TwitterClient.consumerSecret,
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl: "https://api.twitter.com/oauth/authorize",
        accessTokenUrl: "https://api.twitter.com/oauth/access_token"
    )
    
    static func getInstance() -> TwitterClient? {
        let defaults = UserDefaults.standard
        
        if let oauthToken = defaults.string(forKey: self.oauthTokenKey), let oauthTokenSecret = defaults.string(forKey: self.oauthTokenSecretKey) {
            return TwitterClient(
                consumerKey: self.consumerKey,
                consumerSecret: self.consumerSecret,
                oauthToken: oauthToken,
                oauthTokenSecret: oauthTokenSecret, version: .oauth1)
        }
        
        return nil
    }
    
    static func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        TwitterClient.oauthSwift.authorize(
            withCallbackURL: URL(string: "ZhaoTweet://zhaolongzhong.com/twitter")!,
            success: { (credential, response, parameters) -> Void in
                
                //todo: remove
                print(credential.oauthToken)
                print(credential.oauthTokenSecret)
                print(parameters["user_id"])
                print("login success")
                
                let defaults = UserDefaults.standard
                defaults.set(credential.oauthToken, forKey: TwitterClient.oauthTokenKey)
                defaults.set(credential.oauthTokenSecret, forKey: TwitterClient.oauthTokenSecretKey)
                defaults.synchronize()

                success()
            },
            failure: { error in
                print(error.localizedDescription)
                failure(error)
            }
        )
    }
    
    static func handleOpenUrl(url: URL) {
        if (url.host == "zhaolongzhong.com") {
            OAuthSwift.handle(url: url)
        } else {
            print("Error in host.")
        }
    }
    
    func verifyCredentials(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        // todo: replace url with constant
        let params = ["include_entities" : true]
        print(params)
        self.get("https://api.twitter.com/1.1/account/verify_credentials.json", parameters: params, success: { (data, response) -> Void in
            guard let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                print("Response cannot be parsed as JSONArray.")
                return
            }
            
            print("credential: \(dictionary)")
            let realm = AppDelegate.getInstance().realm!
            let user = User()
            
            do {
                try user.mapFrom(dictionary: dictionary)
                user.isDefault = true
                realm.beginWrite()
                realm.add(user, update: true)
                try realm.commitWrite()
            } catch let error {
                print(error)
                realm.cancelWrite()
            }
            
            let defaults = UserDefaults.standard
            defaults.set(user.id, forKey: "DefaultUserIdKey")
            defaults.synchronize()
            
            success(user)
        }) { (error) -> Void in
            print("there was an error: \(error)")
            failure(error)
        }
    }
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        // todo: replace url with constant
        self.get("https://api.twitter.com/1.1/statuses/home_timeline.json", parameters: [:], success: { (data, response) -> Void in
            guard let dictionaries = try! JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary] else {
                print("Response cannot be parsed as JSONArray.")
                return
            }
            
            success(Tweet.mapFrom(array: dictionaries, type: Tweet.homeTimeline))
        }) { (error) -> Void in
            print("there was an error: \(error)")
            failure(error)
        }
    }
    
    func mentionsTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        // todo: replace url with constant
        self.get("https://api.twitter.com/1.1/statuses/mentions_timeline.json", parameters: [:], success: { (data, response) -> Void in
            guard let dictionaries = try! JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary] else {
                print("Response cannot be parsed as JSONArray.")
                return
            }
            
            success(Tweet.mapFrom(array: dictionaries, type: Tweet.mentionsTimeline))
        }) { (error) -> Void in
            print("there was an error: \(error)")
            failure(error)
        }
    }
    
    func userTimeline(screenName: String, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        // todo: replace url with constant
        var params = [String: AnyObject]()
        params["screen_name"] = screenName as AnyObject
        params["include_entities"] = true as AnyObject
        
        self.get("https://api.twitter.com/1.1/statuses/user_timeline.json", parameters: params, success: { (data, response) -> Void in
            guard let dictionaries = try! JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary] else {
                print("Response cannot be parsed as JSONArray.")
                return
            }
            
            success(Tweet.mapFrom(array: dictionaries, type: Tweet.userTimeline))
        }) { (error) -> Void in
            print("there was an error: \(error)")
            failure(error)
        }
    }
    
    func postTweet(tweetText: String, tweetId: String?, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) -> ()) {
        var params: [String : String] = ["status" : tweetText]
        
        if let id = tweetId {
            params["in_reply_to_status_id"] = "\(id)"
        }
        
        print(params)
        
        // todo: replace url with constant
        self.post("https://api.twitter.com/1.1/statuses/update.json", parameters: params, headers: nil, success: { (data, response) -> Void in
            // return a Tweet dictionary if success
            if let dictionary =  try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(dictionary)
                success(dictionary)
            }
            
        }, failure: {(error) -> Void in
            print(error)
            failure(error)
        })
    }
    
    func favorite(tweetId: String, favorited: Bool, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) -> ()) {
        let params: [String : String] = ["id" : tweetId]
        let url = "https://api.twitter.com/1.1/\(favorited ? "favorites/create.json" : "favorites/destroy.json")"
        self.post(url, parameters: params, headers: nil, success: { (data, response) -> Void in
            // return a Tweet dictionary if success
            if let dictionary =  try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(dictionary)
                success(dictionary)
            }
            
            }, failure: {(error) -> Void in
                print(error)
                failure(error)
        })

    }
    
    func retweet(tweetId: String, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) -> ()) {
        let url = "https://api.twitter.com/1.1/statuses/retweet/\(tweetId).json"
        
        self.post(url, parameters: [:], headers: nil, success: { (data, response) -> Void in
            if let dictionary =  try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(dictionary)
                success(dictionary)
            }
            
            }, failure: {(error) -> Void in
                print(error)
                failure(error)
        })
        
    }
}
