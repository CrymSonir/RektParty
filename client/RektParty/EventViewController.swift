//
//  EventViewController.swift
//  RektParty
//
//  Created by stagiaire on 21/03/2017.
//  Copyright © 2017 The Grilled Birds. All rights reserved.
//

import UIKit
import GooglePlaces
import Alamofire
import JWT
import SwiftyJSON

class EventViewController: UIViewController {

    let placesClient: GMSPlacesClient? = nil
    
    var placeAddress: String = ""
    var placeLatitude: String = ""
    var placeLongitude: String = ""
    
    @IBOutlet weak var btnCloseModal: UIButton!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var addressAutocomplete: UITextField!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var privateEventSwitch: UISwitch!
    @IBOutlet weak var saveEventBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Disabled send button by default
        saveEventBtn.isEnabled = false
        saveEventBtn.alpha = 0.5
        
        // Do any additional setup after loading the view.
        privateEventSwitch.isOn = false
        
        addressAutocomplete.addTarget(self, action: #selector(addressFieldDidChange(_:)), for: .editingDidBegin)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCloseModalTouchUp(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func eventNameEditingChanged(_ sender: UITextField) {
        checkInputsValues()
    }
    
    @IBAction func saveYourEventTouchUp(_ sender: UIButton) {
        let db = UserDefaults.standard
        let parameters: Parameters = ["name": eventName.text!,
                                      "dateStart": startDate.date,
                                      "dateEnd": endDate.date,
                                      "private": privateEventSwitch.isOn,
                                      "location": placeAddress,
                                      "longitude": placeLongitude,
                                      "latitude": placeLatitude,
                                      "token": db.string(forKey: "token")!
        ]
        Alamofire.request("http://192.168.100.100:4567/event",method: .post, parameters: parameters).responseJSON { response in
            
            if let JSONdata = response.result.value {
                print("JSON: \(JSONdata)")
                let event = JSON(JSONdata)
     
                let eventData: Dictionary<String, String> = [
                    "id": event["_id"]["$oid"].rawString()!,
                    "coordinates": event["coordinates"].rawString()!,
                    "name": event["name"].rawString()!
                ]
                print(eventData)
                
                NotificationCenter.default.post(name: Notification.Name("AddEventToMap"), object: nil, userInfo: eventData)

                let prompt = UIAlertController(title: "Success", message: "Votre event a bien été crée", preferredStyle: UIAlertControllerStyle.alert)
                self.present(prompt, animated: true,completion: nil)
                prompt.addAction(UIAlertAction(title: "validate", style: .default, handler: { action in
                    
                    //self.performSegue(withIdentifier: "backToMap", sender: self)
                    self.dismiss(animated: true)
                    //self.present(self.mapViewController!, animated: true, completion: nil!)
                }))

            }
        }
    }
    
    func addressFieldDidChange(_ textField: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only addresses.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = "FR"
        autocompleteController.autocompleteFilter = filter
        
        let placesClients = GMSPlacesClient()
        placesClients.autocompleteQuery(addressAutocomplete.text!, bounds: nil, filter: filter) { (results, err) in
            if let error = err {
                print(error)
            }
        }
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func checkInputsValues(){
        if eventName.text == ""  || addressAutocomplete.text == "" || String(describing: startDate.date) == "" || String(describing: endDate.date) == "" {
            saveEventBtn.isEnabled = false
            saveEventBtn.alpha = 0.5
        }
        else
        {
            saveEventBtn.isEnabled = true
            saveEventBtn.alpha = 1
        }
    }
}

extension EventViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Print place info to the console.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("place coordinate: \(place.coordinate)")
        
        self.placeLatitude = String(place.coordinate.latitude)
        self.placeLongitude = String(place.coordinate.longitude)
        self.placeAddress = place.formattedAddress!
        self.addressAutocomplete.text = place.formattedAddress
        
        // Close the autocomplete widget.
        dismiss(animated: true, completion: nil)
        checkInputsValues()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
        checkInputsValues()
    }
    
    // Show the network activity indicator.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    // Hide the network activity indicator.
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
