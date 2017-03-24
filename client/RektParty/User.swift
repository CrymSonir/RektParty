//
//  User.swift
//  RektParty
//
//  Created by stagiaire on 24/03/2017.
//  Copyright © 2017 The Grilled Birds. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id:String?
    var name:String?
    var mail:String?
    var pseudo:String?
    var password:String?
    var birthDate:String?
    var firstName:String?
    var lastName:String?

    
    override init(){
        
    }
    init(id: String, name: String,mail: String, pseudo: String, password: String,birthDate: String,firstName: String, lastName: String){
        
        self.id = id
        self.name = name
        self.mail = mail
        self.pseudo = pseudo
        self.password = password
        self.birthDate = birthDate
        self.firstName = firstName
        self.lastName = lastName

    }
  


}
