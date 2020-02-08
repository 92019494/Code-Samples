//
//  Post.swift
//  Traveller
//
//  Created by Anthony on 3/10/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    
    var postID: String
    var placeID: String
    var userID: String
    var userName: String
    var postImageURL: String 
    var placeImageURL: String
    var userImageURL: String
    var placeName: String
    var placeCity: String
    var placeCountry: String
    var placePoints: Int
    var placeCategory: String
    var placeDescription: String
    var placeLatitude: Double
    var placeLongitude: Double
    var reported: [String]
    var created: Timestamp
        
    init(data: [String: Any] ) {
        self.postID = data["postID"] as? String ?? ""
        self.placeID = data["placeID"] as? String ?? ""
        self.userID = data["userID"] as? String ?? ""
        self.userName = data["userName"] as? String ?? ""
        self.postImageURL = data["postImageURL"] as? String ?? ""
        self.placeImageURL = data["placeImageURL"] as? String ?? ""
        self.userImageURL = data["userImageURL"] as? String ?? ""
        self.placeName = data["placeName"] as? String ?? ""
        self.placeCity = data["placeCity"] as? String ?? ""
        self.placeCountry = data["placeCountry"] as? String ?? ""
        self.placePoints = data["placePoints"] as? Int ?? 0
        self.placeCategory = data["placeCategory"] as? String ?? ""
        self.placeDescription = data["placeDescription"] as? String ?? ""
        self.placeLatitude = data["placeLatitude"] as? Double ?? 0
        self.placeLongitude = data["placeLongitude"] as? Double ?? 0
        self.reported = data["reported"] as? [String] ?? [String]()
        self.created = data["created"] as? Timestamp ?? Timestamp()
    }
    
    func pointsString() -> String{
        return String(placePoints) + " Points"
    }
    
    func cityCountryString() -> String{
        return placeCity + ", " + placeCountry
         
    }
}
