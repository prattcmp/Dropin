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

    init(drop: Drop) {
        super.init(nibName: nil, bundle: nil)
        
        self.drop = drop
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dropView = DropView()
        map = dropView.map
        locManager = CLLocationManager()
        
        map.delegate = self
        map.showsUserLocation = true
        let annotation = MKPointAnnotation()
        annotation.coordinate = drop.coordinates
        annotation.title = "@" + (self.drop.from?.username)!
        map.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        map.setRegion(region, animated: false)
        
        dropView.nameLabel.text = "@" + (drop.from?.username)!
        dropView.timeLabel.text = drop.created_at.timeAgoSinceNow()
        
        self.view.addSubview(dropView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "drop-blue")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "drop-blue")
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "drop-blue")!.alpha(0.9)
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
}
