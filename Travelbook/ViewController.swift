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
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    //@IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    //@IBOutlet weak var nameText: UITextField!
    
    //@IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var chosenLatitude = Double() // will be used when someone touches map for 3 seconds
    var chosenLongitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // sets to best accuracy
        locationManager.requestWhenInUseAuthorization()// asks user to agree to use
        locationManager.startUpdatingLocation()// starts use of location
        let  gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))// standard action with selecter being a objc func and identify the function to be called
        gestureRecognizer.minimumPressDuration = 3 // hold for 3 secs
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {// Needs GestureRecogniser here to work upon
        if gestureRecognizer.state == .began {// has it received touch object and received touch points to get coordinates
            let touchedPoint = gestureRecognizer.location(in: self.mapView) // uses the mapView location
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)// converts coordinated to a mapView
            chosenLatitude = touchedCoordinates.latitude // only available after defining variable
            chosenLongitude = touchedCoordinates.longitude
            //Need now to create Pin
            let annotation = MKPointAnnotation()
            //Next give coordinates to Pin and add title etc
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text // "New Annotation"
            annotation.subtitle = commentText.text //"Travel Book"
            self.mapView.addAnnotation(annotation)
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude
            , longitude: locations[0].coordinate.longitude)// sets up locations array with the coordinates
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // gives the accuracy required for location
        let region = MKCoordinateRegion(center: location, span: span) // you canuse existing location in Debug like Apple HQ or input your own!
        mapView.setRegion(region, animated: true) // calls map with the region and span selected
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        // take position and assign the data to it
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        // save data using do catch errors
        
        do {
            try context.save()
            print("Success")
        } catch {
            print("Error")
        }
    }
    
    

}

