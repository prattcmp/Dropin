//
//  MapViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/11/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import MapKit
import SnapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    var pageIndex: Int!
    
    var mapView: MapView!
    var map: MKMapView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var success = false
        
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                while (success == false) {
                    success = true
                    Drop.getByToID(id: currentUser.id) { (isSuccess: Bool, username: String, drops: [Drop]) in
                        if (isSuccess) {
                            DispatchQueue.main.async {
                                for drop in drops {
                                    let annotation = TypedPointAnnotation()
                                    annotation.type = "drop-blue"
                                    annotation.coordinate = drop.coordinates
                                    annotation.title = "@" + (drop.from?.username)!
                                    self.map.addAnnotation(annotation)
                                }
                            }
                        } else {
                            success = false
                        }
                    }
                    
                    if success == false {
                        continue
                    }
                    
                    Drop.getByFromID(id: currentUser.id) { (isSuccess: Bool, username: String, drops: [Drop]) in
                        if (isSuccess) {
                            DispatchQueue.main.async {
                                for drop in drops {
                                    let annotation = TypedPointAnnotation()
                                    annotation.type = "drop-green"
                                    annotation.coordinate = drop.coordinates
                                    annotation.title = "@" + (drop.from?.username)!
                                    self.map.addAnnotation(annotation)
                                }
                            }
                        } else {
                            success = false
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MapView()
        map = mapView.map
        
        map.delegate = self
        map.showsUserLocation = true
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.sendDropPressed(_:)))
        longPressRecognizer.delegate = self;
        self.mapView.addGestureRecognizer(longPressRecognizer)
        
        // Show the map
        self.view.addSubview(mapView)
        
        mapView.centerButton?.addTarget(self, action: #selector(centerButtonPressed), for: .touchUpInside)
        
    }
    
    func centerButtonPressed(_ sender: AnyObject?) {
        if let coords = map.userLocation.location?.coordinate {
            let coordRegion = MKCoordinateRegionMakeWithDistance(coords, 500, 500)
            map.setRegion(coordRegion, animated: false)
        }
    }
    
    func sendDropPressed(_ gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self.map)
            let coordinates = self.map.convert(point, toCoordinateFrom: self.map)
            
            navController.pushViewController(SendDropViewController(currentUser: currentUser, coordinates: coordinates), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let typedAnnotation = annotation as! TypedPointAnnotation
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: typedAnnotation.type)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: typedAnnotation.type)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: typedAnnotation.type)!.alpha(0.9)
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
    
    // Allows the send drop view to open, even when we long press on the blue dot
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
