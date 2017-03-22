//
//  RegisterViewController.swift
//  RektParty
//
//  Created by stagiaire on 21/03/2017.
//  Copyright © 2017 The Grilled Birds. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController {

    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var birthDate: UIDatePicker!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickRegister(_ sender: UIButton) {
        var userData = [String: String]()
        
        print(self.mail != nil)
        
        if ( self.mail != nil && self.nickName != nil && self.firstName !=  nil
            && self.password != nil && self.birthDate != nil && self.lastName != nil && self.password != nil ) {
            print("toto")
            userData["mail"] = self.mail.text!
            userData["password"] = self.password.text!
            userData["pseudo"] = self.nickName.text!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from:self.birthDate.date)
            userData["birthDate"] = dateString
            userData["firstName"] = self.firstName.text!
            userData["lastName"] = self.lastName.text!
            
            do {
                //Convert to Data
                let jsonData = try! JSONSerialization.data(withJSONObject: userData, options: JSONSerialization.WritingOptions.prettyPrinted)
                
                //Convert back to string. Usually only do this for debugging
                if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                    print(JSONString)
                }
                
                //In production, you usually want to try and cast as the root data structure. Here we are casting as a dictionary. If the root object is an array cast as [AnyObject].
                let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
                Alamofire.request("http://192.168.100.100:4567/register", method: .post, parameters: json)
                    .responseJSON { response in
                        print("Register Succes")   // result of response serialization
                }
                self.dismiss(animated: true)
            } catch {
                print("JSON Fail")
            }
        }

    }


}
