//
//  ViewController.swift
//  Travelbook
//
//  Created by Jim Allan on 17/06/2020.
//  Copyright © 2020 Jim Allan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // sets to best accuracy
        locationManager.requestWhenInUseAuthorization()// asks user to agree to use
        locationManager.startUpdatingLocation()// starts use of location
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude
            , longitude: locations[0].coordinate.longitude)// sets up locations array with the coordinates
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // gives the accuracy required for location
        let region = MKCoordinateRegion(center: location, span: span) // you canuse existing location in Debug like Apple HQ or input your own!
        mapView.setRegion(region, animated: true) // calls map with the region and span selected
    }

}

