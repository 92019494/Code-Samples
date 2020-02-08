//
//  User.swift
//  Traveller
//
//  Created by Anthony on 30/09/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import Foundation
import MapKit
import FirebaseStorage
import FirebaseFirestore


struct User {
    
    var id: String
    var name: String
    var email: String
    var searchRadius: Int
    var country: String
    var instagramUsername: String
    var points: Int
    var imageURL: String
    var worldwide: Bool
    var isPrivate: Bool
    var hintsEnabled: Bool
    var posts: Int
    var placesVisited: Int
    var achievements: [String]
    var activities: [String]
    var seen: [String]
    var created: Date?
    var profileImage = UIImage()
    var lastPlaceVisited: String
    
    init(data: [String: Any] ) {
        self.id = data["id"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.searchRadius = data["searchRadius"] as? Int ?? 0
        self.country = data["country"] as? String ?? ""
        self.instagramUsername = data["instagramUsername"] as? String ?? ""
        self.points = data["points"] as? Int ?? 0
        self.imageURL = data["imageURL"] as? String ?? ""
        self.worldwide = data["worldwide"] as? Bool ?? false
        self.isPrivate = data["isPrivate"] as? Bool ?? false
        self.hintsEnabled = data["hintsEnabled"] as? Bool ?? true
        self.posts = data["posts"] as? Int ?? 0
        self.placesVisited = data["placesVisited"] as? Int ?? 0
        self.achievements = data["achievements"] as? [String] ?? [String]()
        self.activities = data["activities"] as? [String] ?? [String]()
        self.seen = data["seen"] as? [String] ?? [String]()
        self.created = data["created"] as? Date ?? Date()
        self.lastPlaceVisited = data["lastPlaceVisited"] as? String ?? ""
        
    }
    
    func pointsString() -> String{
        return String(points) + " Points"
    }
    
}
