//
//  Achievement.swift
//  Traveller
//
//  Created by Anthony on 30/09/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import Foundation

struct Achievement {
    
    var id: Int
    var name: String
    var description: String
    var color: String
    var unlocked: Bool
    
    init(id: Int, name: String, description: String, color: String, unlocked: Bool ) {
        self.id = id
        self.name = name
        self.description = description
        self.unlocked = unlocked
        
        switch color {
        case "bronze":
            self.color = "icon-badge-bronze"
        case "silver":
            self.color = "icon-badge-silver"
        case "gold":
            self.color = "icon-badge-gold"
        default:
            self.color = "icon-badge-bronze"
        }

    }
    
    init(data: [String: Any] ) {
        self.id = data["id"] as? Int ?? 0
        self.name = data["name"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.color = data["color"] as? String ?? ""
        self.unlocked = data["unlocked"] as? Bool ?? false
    }
    

}
