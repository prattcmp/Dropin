//
//  DropViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 10/28/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import MapKit

class DropViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var drop: Drop!
    
    var dropView: DropView!
    var map: MKMapView!
    var locManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D!

    var directionsUpdated = false
    
    init(drop: Drop, mapViewController: MapViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.drop = drop
        
        mapViewController.zoomOnCoordinates(drop.coordinates, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(self.drop.read == false && drop.from?.username != currentUser.username) {
            self.drop.markRead(done: { (isSuccess, message) in
                if(!isSuccess) {
                    print("There was a problem marking the drop as read.")
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dropView = DropView()
        map = dropView.map
        
        map.delegate = self
        map.showsUserLocation = true
        
        self.locManager = CLLocationManager()
        self.locManager.delegate = self
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locManager.requestWhenInUseAuthorization()
        self.locManager.startUpdatingLocation()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = drop.coordinates
        annotation.title = "@" + (self.drop.from?.username)!
        map.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        map.setRegion(region, animated: false)

        dropView.backButton.setTitle((drop.from!.name), for: .normal)
        dropView.backButton.setTitleColor(.white, for: .normal)
        dropView.backButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, -5.0)
        dropView.timeLabel.text = drop.created_at.timeAgoSinceNow()
        dropView.textLabel.text = drop.text
        dropView.backButton.sizeToFit()
        dropView.textLabel.sizeToFit()
        if drop.text == "" {
            dropView.detailZone.isHidden = true
        }
        
        self.view.addSubview(dropView)
        
        dropView.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        dropView.getDirectionsButton.addTarget(self, action: #selector(openMaps), for: .touchUpInside)
    }
    
    @objc func openMaps() {
        let regionDistance: CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegionMakeWithDistance(drop.coordinates, regionDistance, regionDistance)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        let placemark = MKPlacemark(coordinate: drop.coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = (drop.from?.name)! + "'s Drop"
        mapItem.openInMaps(launchOptions: options)
    }
    
    func updateDirections() {
        self.directionsUpdated = true
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: drop.coordinates, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.map.add(route.polyline)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        let pastLocation = self.userLocation
        
        self.userLocation = location
        
        if !(self.directionsUpdated) && (pastLocation?.latitude != userLocation.latitude) && (pastLocation?.longitude != userLocation.longitude) {
            self.updateDirections()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var identifier = "drop-blue"
        if drop.from == currentUser {
            identifier = "drop-green"
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: identifier)!.alpha(0.9)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pinToZoomOn = view.annotation
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: pinToZoomOn!.coordinate, span: span)
        
        map.setRegion(region, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    @objc func goBack() {
        navController.popViewController(animated: true)
    }
}
