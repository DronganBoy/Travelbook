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
    
    var selectedTitle = ""
    var selectedTitleID : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
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
        
        if selectedTitle != "" {
            //IF NOT EMPTY GO TO CoreData TO GET INFORMATION
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            //print(stringUUID)
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                   
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let subTitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subTitle
                            
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                    }
                                
                                }
                            
                            
                            }
                            
                        }
                        
                        
                    }
                    
                }
            } catch {
                print("error")
            }
        } else {
            // DO NOTHING SINCE USER IS LIKELY TO BE AddING New Data
        }
    }
    // next function is to put a disclosure button on the pin, it will bring a navigation to the selected place
    // there is a fubtion to customise pin
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { //viewforannotion brings this up
            return nil // return
        }
        
        let reuseId = "myAnnotation"
        // next line defines a variable and drags it from the mapView
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {// if not empty string then we have a chosen latitute/longditude
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in// Creates placemark
                //closure
                
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)//brings up navigation options
                        item.name = self.annotationTitle
                        // now get launchoptions but first needed to create placemerks above
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                                           
                }
                    
                
                
                
                }
                
                
               
            }
            
        }
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
        
        if selectedTitle == "" {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude
            , longitude: locations[0].coordinate.longitude)// sets up locations array with the coordinates
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // gives the accuracy required for location
        let region = MKCoordinateRegion(center: location, span: span) // you canuse existing location in Debug like Apple HQ or input your own!
        mapView.setRegion(region, animated: true) // calls map with the region and span selected
        } else {
            // do nothing, don't update
        }
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
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)// aim is to send a message to anywhere in app to trigger action, the function will be getting data from core data
        navigationController?.popViewController(animated: true) // This will take us back to ListVC
    
    }
    
        

}

