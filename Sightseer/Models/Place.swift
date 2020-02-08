//
//  Place.swift
//  Traveller
//
//  Created by Anthony on 1/10/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Place {
     
    var id: String
    var name: String
    var description: String
    var category: String
    var country: String
    var city: String
    var points: Int
    var imageURL: String
    var latitude: Double
    var longitude: Double 
    var reported: [String]
    var verified: Bool
    var placeImage = UIImage()
    var checkedInCount: Int
    var distanceFromUser: Double?
    
    init(id: String, name: String, description: String, category:String, country: String, city: String, points: Int, latitude: Double, longitude: Double, reported: [String], verified: Bool, checkedInCount: Int, imageURL: String) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.country = country
        self.city = city
        self.points = points
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.reported = reported
        self.verified = verified
        self.checkedInCount = checkedInCount
     }
     
     init(data: [String: Any] ) {
        self.id = data["id"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.category = data["category"] as? String ?? ""
        self.country = data["country"] as? String ?? ""
        self.city = data["city"] as? String ?? ""
        self.points = data["points"] as? Int ?? 0
        self.imageURL = data["imageURL"] as? String ?? ""
        self.longitude = data["longitude"] as? Double ?? 0
        self.latitude = data["latitude"] as? Double ?? 0
        self.reported = data["reported"] as? [String] ?? [String]()
        self.verified = data["verified"] as? Bool ?? false
        self.checkedInCount = data["checkedInCount"] as? Int ?? 0
     }
    
    func pointsString() -> String{
        return String(points) + " Points"
    }
    
    func cityCountryString() -> String{
        return city + ", " + country
         
    }
 }
