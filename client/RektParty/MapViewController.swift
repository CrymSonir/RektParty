//
//  MapControllerViewController.swift
//  RektParty
//
//  Created by stagiaire on 20/03/2017.
//  Copyright © 2017 The Grilled Birds. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreFoundation
import Alamofire

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addMarkerBtn: RoundButton!
    
    var markersList: [GMSMarker] = []
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.AddEventToMap(notification:)),
            name: Notification.Name("AddEventToMap"),
            object: nil)
        
        addMarkerBtn.layer.shadowColor = UIColor.black.cgColor
        addMarkerBtn.layer.shadowOpacity = 0.7
        addMarkerBtn.layer.shadowOffset = CGSize.zero
        addMarkerBtn.layer.shadowRadius = 2
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        // The myLocation attribute of the mapView may be null
        if let mylocation = mapView.myLocation {
            print("User's location: \(mylocation)")
            //Location Manager code to fetch current location
        } else {
            print("User's location is unknown")
        }
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        getMarkers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:14)
        mapView.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func getMarkers(){
        // TODO GET CREATED MARKER BY USER
        let db = UserDefaults.standard
        let parameters: Parameters = ["token": db.string(forKey: "token")!]
        Alamofire.request("http://192.168.100.100:4567/event/all",method: .get, parameters: parameters).responseString { response in
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
                
                let jsonData = try? JSONSerialization.jsonObject(with: JSON.data(using: .utf8)!, options: [])
                NotificationCenter.default.post(name: Notification.Name("AddEventToMap"), object: nil, userInfo: jsonData as! [AnyHashable : Any]?)
                self.dismiss(animated: true)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let db = UserDefaults.standard
        if (db.object(forKey: "isLog") as? Bool) == nil {
            self.performSegue(withIdentifier: "loginView", sender: self)
        }
    }

    @IBAction func onClickLogOut(_ sender: UIButton) {
        let db = UserDefaults.standard
        db.set(nil, forKey: "isLog")
        db.set(nil, forKey: "userData")
        
        self.performSegue(withIdentifier: "loginView", sender: self)
    }

    func AddEventToMap(notification: Notification){
        //Take Action on Notification
        print(notification.userInfo!["_id"]!)
        let stringCoordinates = (notification.userInfo!["coordinates"] as! String).components(separatedBy: "|")
        let markerPosition = CLLocationCoordinate2DMake(Double(stringCoordinates[0])!, Double(stringCoordinates[1])!)
        let marker = GMSMarker(position: markerPosition)
        marker.title = notification.userInfo!["name"] as? String
        marker.icon = UIImage(named: "marker")
        markersList.append(marker)
        marker.map = self.mapView
        self.mapView.selectedMarker = marker
        self.mapView.animate(toLocation: markerPosition)

    }
    
}
