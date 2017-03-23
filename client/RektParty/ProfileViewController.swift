//
//  ProfileViewController.swift
//  RektParty
//
//  Created by stagiaire on 21/03/2017.
//  Copyright © 2017 The Grilled Birds. All rights reserved.
//

import UIKit
import Alamofire
import JWT

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtNickname: UITextField!
    @IBOutlet weak var dpBirthDate: UIDatePicker!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = UserDefaults.standard
        let userData = db.object(forKey: "userData") as! NSDictionary
        self.txtMail.text = (userData["mail"] as! String)
        self.txtNickname.text = (userData["pseudo"] as! String)
        self.txtFirstName.text = (userData["firstName"] as! String)
        self.txtLastName.text = (userData["lastName"] as! String)
        //print(userData["birthDate"]!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
        let dateFormated = dateFormatter.date(from: userData["birthDate"] as! String)
        //print(dateFromated!)
        self.dpBirthDate.date = dateFormated!
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func editProfile(_ sender: UIButton) {
        let db = UserDefaults.standard
        let token = db.string(forKey: "token")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: dpBirthDate.date)
        print("password : " + txtPassword.text!)
        var parameters: Parameters;
        if txtPassword.text != "" {
            print("password")
            parameters = ["mail": txtMail.text!, "password": txtPassword.text!,
                          "firstName": txtFirstName.text!,"lastName": txtLastName.text!,
                          "birthDate": dateString,"pseudo": txtNickname.text!,"token": token!];
            
        }else{
            print("no password")
            parameters = ["mail": txtMail.text!,
                          "firstName": txtFirstName.text!,"lastName": txtLastName.text!,
                          "birthDate": dateString,"pseudo": txtNickname.text!,"token":token!];
        }
        Alamofire.request("http://192.168.100.100:4567/user",method: .put, parameters: parameters).responseString { response in
            
            if let JSON = response.result.value {
                do {
                    // let allo:String = JSON as! String
                    let db = UserDefaults.standard
                    let result = try JWT.decode(JSON, algorithm: .hs256("my$ecretK3y".data(using: .utf8)!))
                    let userData = [
                        "pseudo":result["pseudo"],
                        "birthDate":result["birthDate"],
                        "lastName":result["lastName"],
                        "firstName":result["firstName"] ,
                        "mail":result["mail"]
                        
                    ]
                    
                    db.set(JSON, forKey: "token")
                    db.set(true, forKey: "isLog")
                    db.set(userData, forKey: "userData")
                    let prompt = UIAlertController(title: "Modification réussi", message: "Modification réussi", preferredStyle: .alert)
                    let action = UIAlertAction(title: "ok", style: .default, handler: nil)
                    prompt.addAction(action)
                    self.present(prompt, animated: true)
                    self.viewDidLoad()
                    
                } catch {
                    print("ERROR TOKEN : \(error)")
                }
            }
        }
        

    }
}
