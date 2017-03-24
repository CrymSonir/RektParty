//
//  Event.swift
//  RektParty
//
//  Created by stagiaire on 23/03/2017.
//  Copyright © 2017 The Grilled Birds. All rights reserved.
//

import UIKit

class Event: NSObject {
    
    var id:String?
    var name:String?
    var dateStart:String?
    var dateEnd:String?
    var privateP:String?
    var status:String?
    var location:String?
    var coordinates:String?
    var organisatorId:String?
    
    
    init(id: String, name: String,dateStart: String, dateEnd: String, privateP: String,status: String,location: String, coordinates: String,organisatorId: String){
        
        self.id = id
        self.name = name
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.privateP = privateP
        self.status = status
        self.location = location
        self.coordinates = coordinates
        self.organisatorId = organisatorId
    }


}
