//
//  MapViewController.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/22/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet private weak var mapView: MKMapView!
    @IBAction private func addPin(sender: UILongPressGestureRecognizer) {
        guard sender.state == .Began else {
            return
        }
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        let touchCoordinates = self.mapView.convertPoint(sender.locationInView(self.mapView), toCoordinateFromView: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchCoordinates
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), completionHandler: {
            (placemarks, error) in
            if let addressDict = placemarks![0].addressDictionary {
                var street = addressDict["Street"] as! String
                if let commaIndex = street.characters.indexOf(",") {
                    street = street.substringToIndex(commaIndex)
                }
                annotation.title = street
            }
            else {
                NSLog("Could not retrieve address.")
                if placemarks == nil {
                    NSLog("Placemarks is nil")
                } else {
                    NSLog("Placemarks: %s", placemarks!)
                }
                if error != nil {
                    NSLog("Error: %s", error!)
                }
            }
            }
        )
        
        self.mapView.addAnnotation(annotation)
    }
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select street"
        self.descriptionLabel.text = "Touch and hold over a street to create a pin. Touch the pin to open a callout with the street\'s name. Touch the callout icon to search routes from that street."
        
        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.NotDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        else if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self.showAndUpdateUserLocation()
        }
    }

    private func showAndUpdateUserLocation()
    {
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Delegates
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self.showAndUpdateUserLocation()
        }
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        /// zooms the map to the user location on first load
        if mapView.annotations.count == 1 && mapView.annotations.first!.isKindOfClass(MKUserLocation) {
            mapView.showAnnotations(mapView.annotations, animated: true)
            return
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKindOfClass(MKUserLocation) else {
            return nil
        }
        
        let annotationView = MKPinAnnotationView()
        annotationView.annotation = annotation
        annotationView.canShowCallout = true
        annotationView.pinTintColor = UIColor.redColor()
        annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard self.navigationController != nil else {
            return
        }
        
        if let listVC = self.navigationController!.viewControllers[0] as? ListViewController {
            listVC.streetToSearch = (view.annotation?.title)!
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
}
