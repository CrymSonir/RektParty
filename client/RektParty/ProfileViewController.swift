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

    @IBOutlet weak var txtNickName: UITextField!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var dpBirthDate: UIDatePicker!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = UserDefaults.standard
        let userData = db.object(forKey: "userData") as! NSDictionary
        self.txtMail.text = (userData["mail"] as! String)
        self.txtNickName.text = (userData["pseudo"] as! String)
        self.txtFirstName.text = (userData["firstName"] as! String)
        self.txtLastName.text = (userData["lastName"] as! String)
        //print(userData["birthDate"]!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yyyy" //Your date format
        let dateFromated = dateFormatter.date(from: userData["birthDate"] as! String)
        //print(dateFromated!)
        self.dpBirthDate.date = dateFromated!

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func editProfile(_ sender: UIButton) {
        
        let db = UserDefaults.standard
        let token = db.string(forKey: "token")
        print("token" + token!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yyyy"
        let dateString = dateFormatter.string(from: dpBirthDate.date)
        var parameters: Parameters;
        if txtPassword.text != "" {
             parameters = ["mail": txtMail.text!, "password": txtPassword.text!,
                                          "fisrtName": txtFirstName.text!,"lastName": txtLastName.text!,
            "birthDate": dateString,"pseudo": txtNickName.text!,"token": token!];
            print("here")
        }else{
             parameters = ["mail": txtMail.text!,
                        "fisrtName": txtFirstName.text!,"lastName": txtLastName.text!,
                        "birthDate": dateString,"pseudo": txtNickName.text!,"token":token!];
        }
        print("===========================" + token!)
        Alamofire.request("http://192.168.100.100:4567/user",method: .put, parameters: parameters).responseString { response in
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
                do {
                    // let allo:String = JSON as! String
                    
                    let result = try JWT.decode(JSON, algorithm: .hs256("my$ecretK3y".data(using: .utf8)!))
                    print(result)
                    /*let db = UserDefaults.standard
                    let userData = db.object(forKey: "userData") as! NSDictionary
                   
                    serData["mail"] = self.txtMail.text!*/
                    /*userData["pseudo"] = self.txtFirstName.text!
                    userData["firstName"] =self.txtFirstName.text!
                    userData["lastName"] =self.txtFirstName.text!
                    userData["birthDate"] = self.txtFirstName.text!

                    let userData = [
                        "pseudo":result["pseudo"],
                        "birthDate":result["birthDate"],
                        "lastName":result["lastName"],
                        "firstName":result["firstName"] ,
                        "mail":result["mail"],
                        "token": JSON
                    ]
                    
                    db.set(true, forKey: "isLog")
                    db.set(userData, forKey: "userData")
                    self.dismiss(animated: true)*/
                    self.viewDidLoad()
                } catch {
                    print("ERROR TOKEN : \(error)")
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
