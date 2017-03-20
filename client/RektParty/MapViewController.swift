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

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
   // @IBOutlet weak var addMarkerBtn: UIButton!
    
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
        
        /*addMarkerBtn.contentVerticalAlignment = .center
        
        addMarkerBtn.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
        addMarkerBtn.layer.cornerRadius = 0.5 * addMarkerBtn.bounds.size.width
        addMarkerBtn.clipsToBounds = true
        view.addSubview(addMarkerBtn)*/
        
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
        let markerPosition = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
        let marker = GMSMarker(position: markerPosition)
        marker.title = "Me"
        marker.map = mapView
        marker.icon = UIImage(named: "marker")
        mapView.selectedMarker = marker
        mapView.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func getMarkers(){
        // TODO GET CREATED MARKER BY USER
        
        var markerPosition = CLLocationCoordinate2DMake(45.770301, 4.86365)
        var marker = GMSMarker(position: markerPosition)
        marker.title = "Orgie a lyon"
        marker.icon = UIImage(named: "marker")
        markersList.append(marker)
        marker.map = self.mapView
        
        markerPosition = CLLocationCoordinate2DMake(46.770301, 4.86365)
        marker = GMSMarker(position: markerPosition)
        marker.title = "Orgie a paris"
        marker.icon = UIImage(named: "marker")
        markersList.append(marker)
        marker.map = self.mapView
        
        markerPosition = CLLocationCoordinate2DMake(47.770301, 4.86365)
        marker = GMSMarker(position: markerPosition)
        markersList.append(marker)
        marker.title = "Orgie chez ta mere"
        marker.icon = UIImage(named: "marker")
        marker.map = self.mapView
    }

//    override func viewDidAppear(_ animated: Bool) {
//        self.performSegue(withIdentifier: "loginView", sender: self)
//    }
    
}
