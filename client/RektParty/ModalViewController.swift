//
//  ModalViewController.swift
//  RektParty
//
//  Created by stagiaire on 21/03/2017.
//  Copyright © 2017 The Grilled Birds. All rights reserved.
//

import UIKit
import GooglePlaces

class ModalViewController: UIViewController {

    let placesClient: GMSPlacesClient? = nil
    
    var placeAddress: String = ""
    var placeLatitude: String = ""
    var placeLongitude: String = ""
    
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var addressAutocomplete: UITextField!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var privateEventSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        privateEventSwitch.isOn = false
        
        addressAutocomplete.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveYourEventTouch(_ sender: UIButton) {

    }
    
    func textFieldDidChange(_ textField: UITextField) {
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
}

extension ModalViewController: GMSAutocompleteViewControllerDelegate {
    
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
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
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
