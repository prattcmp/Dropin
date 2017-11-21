//
//  MapViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/11/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import SnapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate {
    var pageIndex: Int!
    
    var mapView: MapView!
    var map: MKMapView!
    var textField: UITextView!
    
    var drops = [Drop]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var success = false
        
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                while (success == false) {
                    success = true
                    
                    Drop.getByToID(id: currentUser.id) { (isSuccess: Bool, username: String, toDrops: [Drop]) in
                        if (isSuccess) {
                            Drop.getByFromID(id: currentUser.id) { (isSuccess: Bool, username: String, fromDrops: [Drop]) in
                                if (isSuccess) {
                            
                                    DispatchQueue.main.async {
                                        self.map.removeAnnotations(self.map.annotations)
                                        
                                        self.drops = [Drop]()
                                        
                                        for drop in toDrops {
                                            let annotation = TypedPointAnnotation()
                                            annotation.type = "drop-blue"
                                            annotation.coordinate = drop.coordinates
                                            annotation.title = "@" + (drop.from?.username)!
                                            annotation.id = self.drops.count
                                            
                                            self.map.addAnnotation(annotation)
                                            self.drops.append(drop)
                                        }
                                        for drop in fromDrops {
                                            let annotation = TypedPointAnnotation()
                                            annotation.type = "drop-green"
                                            annotation.coordinate = drop.coordinates
                                            annotation.title = "@" + (drop.to?.username)!
                                            annotation.id = self.drops.count
                                            
                                            self.map.addAnnotation(annotation)
                                            self.drops.append(drop)
                                        }
                                    }
                                } else {
                                    success = false
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MapView()
        map = mapView.map
        textField = mapView.textField
        
        map.delegate = self
        textField.delegate = self
        
        map.showsUserLocation = true

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTextField))
        
        map.addGestureRecognizer(tap)
        
        // Show the map
        self.view.addSubview(mapView)
        
        mapView.centerButton?.addTarget(self, action: #selector(centerButtonPressed), for: .touchUpInside)
        mapView.sendDropButton?.addTarget(self, action: #selector(sendDropPressed), for: .touchUpInside)
    }
    
    @objc func centerButtonPressed(_ sender: AnyObject?) {
        if let coords = map.userLocation.location?.coordinate {
            let coordRegion = MKCoordinateRegionMakeWithDistance(coords, 500, 500)
            map.setRegion(coordRegion, animated: true)
        }
    }
    
    @objc func dismissTextField() {
        mapView.endEditing(true)
        textField.isHidden = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // If the user hits "Send"
        if(text == "\n") {
            textField.resignFirstResponder()
            textField.isHidden = true
            
            navController.pushViewController(SendDropViewController(currentUser: currentUser, coordinates: map.centerCoordinate, text: textView.text ?? ""), animated: true)
            
            return false
        }
        
        resizeTextView(textView)
        
        return (textView.text.count - range.length + text.count) < 128
    }
    
    func resizeTextView(_ textView: UITextView) {
        // Resize window based on number of lines
        let fixedWidth = textView.frame.size.width
        let oldHeight = textView.frame.height
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        textView.frame.origin.y += oldHeight - newFrame.height
    }
    
    @objc func sendDropPressed(_ sender: AnyObject?) {
        textField.text = ""
        resizeTextView(self.textField)
        textField.isHidden = false
        textField.becomeFirstResponder()
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
        
        map.setRegion(region, animated: true)
        
        if let typedAnnotation = view.annotation as? TypedPointAnnotation {
            navController.pushViewController(DropViewController(drop: self.drops[typedAnnotation.id]), animated: true)
        }
    }
    
    // Sticks the text field to the top of the keyboard
    @objc func keyboardWillHide() {
        self.textField.frame.origin.y = 0
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if textField.isFirstResponder {
                self.textField.frame.origin.y = UIScreen.main.bounds.height - keyboardSize.height - self.textField.frame.height
            }
        }
    }
}
