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
import SwiftyJSON

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapViewContainer: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addMarkerBtn: RoundButton!

    var markersList: [GMSMarker] = []
    
    var customInfoWindow = Bundle.main.loadNibNamed("CustomGmapInfoWindow", owner: self, options: nil)?[0] as! CustomGmapInfoWindow
    var tappedMarker = GMSMarker()
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
        
        let db = UserDefaults.standard
        if (db.object(forKey: "isLog") as? Bool) == nil {
            mapViewContainer.isHidden = true
            self.performSegue(withIdentifier: "loginView", sender: self)
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.AddEventToMap(notification:)),
                name: Notification.Name("AddEventToMap"),
                object: nil)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.ShowMap(notification:)),
                name: Notification.Name("ShowMap"),
                object: nil)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.GoToEvent(notification:)),
                name: Notification.Name("GoToEvent"),
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
        
        self.locationManager.stopUpdatingLocation()
    }
    
    /// GetMarkers from API
    func getMarkers(){
        let db = UserDefaults.standard
        let parameters: Parameters = ["token": db.string(forKey: "token")!]
        Alamofire.request("http://192.168.100.100:4567/events",method: .get, parameters: parameters).responseJSON { response in
            if let JSONdata = response.result.value as? NSArray{
                let json = JSON(JSONdata)
                for (key, event):(String, JSON) in json {
                    self.AddMarkerToMap(coordinates: event["coordinates"].rawString()!, eventName: event["name"].rawString()!, eventId: event["_id"]["$oid"].rawString()!)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let db = UserDefaults.standard
        if (db.object(forKey: "isLog") as? Bool) == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(vc, animated: false, completion: nil)
            //self.performSegue(withIdentifier: "loginView", sender: self)
        }
    }

    @IBAction func onClickLogOut(_ sender: UIButton) {
        let db = UserDefaults.standard
        db.set(nil, forKey: "isLog")
        db.set(nil, forKey: "userData")
        
        self.performSegue(withIdentifier: "loginView", sender: self)
    }

    func AddEventToMap(notification: Notification){
        let marker: GMSMarker = AddMarkerToMap(coordinates: notification.userInfo!["coordinates"] as! String, eventName: notification.userInfo!["name"] as! String, eventId: notification.userInfo!["id"] as! String)
        
        self.mapView.selectedMarker = marker
        self.mapView.animate(toLocation: marker.position)
    }
    
    func ShowMap(notification: Notification){
        mapViewContainer.isHidden = false
    }
    
    func AddMarkerToMap(coordinates: String, eventName: String, eventId: String) -> GMSMarker {
        let stringCoordinates = (coordinates).components(separatedBy: "|")
        let markerPosition = CLLocationCoordinate2DMake(Double(stringCoordinates[0])!, Double(stringCoordinates[1])!)
        let marker = GMSMarker(position: markerPosition)
        marker.title = eventName
        marker.userData = ["_id": eventId] as Dictionary<String, Any>
        marker.icon = UIImage(named: "marker")
        markersList.append(marker)
        marker.map = self.mapView
        return marker
    }
    
    func buttonDeleteTapped(_ sender: UIButton!) {
        let db = UserDefaults.standard
        print(tappedMarker)
        let parameters: Parameters = ["token": db.string(forKey: "token")!, "_id": (tappedMarker.userData as! Dictionary<String, String>)["_id"]!]
        Alamofire.request("http://192.168.100.100:4567/event",method: .delete, parameters: parameters).responseString { response in
            if let JSONdata = response.result.value {
                if response.response?.statusCode != 200 {
                    print("Error while deleting event")
                }else{
                    self.customInfoWindow.removeFromSuperview()
                    self.tappedMarker.map = nil
                }
            }
        }
    }
    
    func buttonDetailTapped(_ sender: UIButton!) {
        let eventDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        let eventDetailId = (tappedMarker.userData as! Dictionary<String, String>)["_id"]!
        
        loadEventDetail(eventId: eventDetailId) { (event) in
            eventDetailViewController.event = event
            self.present(eventDetailViewController, animated: true, completion: nil)
        }
    }

    func loadEventDetail(eventId: String, completion:@escaping (Event) -> Void){
        let db = UserDefaults.standard
        let parameters: Parameters = ["token": db.string(forKey: "token")!, "_id": eventId]
        Alamofire.request("http://192.168.100.100:4567/event",method: .get, parameters: parameters).responseJSON { response in
            if let JSONdata = response.result.value{
                let json = JSON(JSONdata)
                print(json)
                let event :Event = Event(id: json["_id"].rawString()!, name: json["name"].rawString()!, dateStart: json["dateStart"].rawString()!, dateEnd: json["dateEnd"].rawString()!, privateP: json["privateP"].rawString()!, status: json["status"].rawString()!, location: json["location"].rawString()!, coordinates: json["coordinates"].rawString()!, organisatorId: json["organisatorId"].rawString()!)
                completion(event)
            }
        }
    }
    
    func GoToEvent(notification: Notification){
        
        let theMarker = SearchMarkerById(idMarker: (notification.userInfo!["id"] as! String))
        mapView.selectedMarker = theMarker
        mapView.animate(toLocation: theMarker.position)
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let location = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        
        tappedMarker = marker
        customInfoWindow.removeFromSuperview()
        customInfoWindow = Bundle.main.loadNibNamed("CustomGmapInfoWindow", owner: self, options: nil)?[0] as! CustomGmapInfoWindow
        customInfoWindow.title.text = marker.title
        customInfoWindow.center = mapView.projection.point(for: location)
        customInfoWindow.deleteBtn.addTarget(self, action: #selector(buttonDeleteTapped(_:)), for: .touchUpInside)
        customInfoWindow.detailBtn.addTarget(self, action: #selector(buttonDetailTapped(_:)), for: .touchUpInside)
        self.view.addSubview(customInfoWindow)

        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (tappedMarker.userData != nil){
            let location = CLLocationCoordinate2D(latitude: tappedMarker.position.latitude, longitude: tappedMarker.position.longitude)
            customInfoWindow.center = mapView.projection.point(for: location)
            customInfoWindow.center.y -= 60
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        customInfoWindow.removeFromSuperview()
    }
    
    func SearchMarkerById(idMarker:String) -> GMSMarker {
        var theMarker:GMSMarker? = nil
        for marker in markersList{
            if (marker.userData as! Dictionary<String,String>)["_id"] == idMarker{
                theMarker = marker
            }
        }
        return theMarker!
    }
    
}


