//
//  PlacesVisited.swift
//  Traveller
//
//  Created by Anthony on 23/01/20.
//  Copyright © 2020 EmeraldApps. All rights reserved.
//

import Foundation
import UIKit

/// used in profile view
struct PlaceVisited {
     
    var name: String
    var city: String
    var country: String
    var points: Int
    var imageURL: String
    
    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.city = data["city"] as? String ?? ""
        self.country = data["country"] as? String ?? ""
        self.points = data["points"] as? Int ?? 0
        self.imageURL = data["imageURL"] as? String ?? ""
    }
    
    
    func pointsString() -> String{
           return String(points) + " Points"
       }
    
    func cityCountryString() -> String{
        return city + ", " + country
    }
}
