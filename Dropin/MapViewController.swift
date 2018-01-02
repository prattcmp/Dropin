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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate, MapSearchViewControllerDelegate, LockPickerViewControllerDelegate {
    var pageIndex: Int!
    
    var mapView: MapView!
    var map: MKMapView!
    var textField: UITextView!
    
    var drops = [Drop]()
    
    var lockDuration: Int! = 0
    
    var mapSearchViewController: MapSearchViewController!
    var lockPickerViewController: LockPickerViewController!
    
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
                            DispatchQueue.main.async {
                                for drop in toDrops {
                                    if drop.locked == true {
                                        continue
                                    }
                                    
                                    let annotation = TypedPointAnnotation()
                                    annotation.type = "drop-blue"
                                    annotation.coordinate = drop.coordinates
                                    annotation.title = "@" + (drop.from?.username)!
                                    annotation.id = self.drops.count
                                    
                                    self.map.addAnnotation(annotation)
                                    self.drops.append(drop)
                                }
                            }
                        } else {
                            success = false
                        }
                    }
                    
                    Drop.getByFromID(id: currentUser.id) { (isSuccess: Bool, username: String, fromDrops: [Drop]) in
                        if (isSuccess) {
                            
                            DispatchQueue.main.async {
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
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        self.drops = [Drop]()
        self.map.removeAnnotations(self.map.annotations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MapView()
        map = mapView.map
        textField = mapView.textField
        
        mapSearchViewController = MapSearchViewController()
        mapSearchViewController.delegate = self
        
        lockPickerViewController = LockPickerViewController()
        lockPickerViewController.delegate = self
        self.addChildViewController(lockPickerViewController)
        
        map.delegate = self
        textField.delegate = self
        
        map.showsUserLocation = true

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTextField))
        
        map.addGestureRecognizer(tap)
        
        // Show the map
        self.view.addSubview(mapView)
        
        mapView.centerButton?.addTarget(self, action: #selector(centerButtonPressed), for: .touchUpInside)
        mapView.searchButton?.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        mapView.lockButton.addTarget(self, action: #selector(lockButtonPressed), for: .touchUpInside)
        mapView.sendDropButton?.addTarget(self, action: #selector(sendDropTouchDown), for: .touchDown)
        mapView.sendDropButton?.addTarget(self, action: #selector(sendDropTouchUpOutside), for: .touchUpOutside)
        mapView.sendDropButton?.addTarget(self, action: #selector(sendDropTouchUpInside), for: .touchUpInside)
    }
    
    @objc func centerButtonPressed(_ sender: AnyObject?, _ animated: Bool = true) {
        if sender == nil {
            return
        }
        
        if let coords = map.userLocation.location?.coordinate {
            let coordRegion = MKCoordinateRegionMakeWithDistance(coords, 500, 500)
            map.setRegion(coordRegion, animated: animated)
        }
    }
    
    @objc func searchButtonPressed(_ sender: AnyObject?) {
        mapSearchViewController.updateSearchRegion(coordinates: map.centerCoordinate)
        
        navController.pushViewController(mapSearchViewController, animated: true)
    }
    
    @objc func lockButtonPressed(_ sender: AnyObject?) {
        showLockPicker()
    }
    
    @objc func sendDropTouchDown(_ sender: AnyObject?) {
        mapView.shrinkSendDropRing()
    }
    
    @objc func sendDropTouchUpOutside(_ sender: AnyObject?) {
        mapView.growShrinkSendDropRing()
    }
    
    @objc func sendDropTouchUpInside(_ sender: AnyObject?) {
        mapView.shrinkSendDropRing()
        textField.text = ""
        resizeTextView(self.textField)
        textField.isHidden = false
        textField.becomeFirstResponder()
    }
    
    @objc func dismissTextField() {
        mapView.growShrinkSendDropRing()
        mapView.endEditing(true)
        textField.isHidden = true
    }
    
    func showLockPicker() {
        self.mapView.addSubview(self.lockPickerViewController.view)
        self.mapView.hideMapIcons()
    }
    
    func hideLockPicker(sender: LockPickerViewController, lockDuration: Int) {
        self.lockDuration = lockDuration
        
        sender.view.removeFromSuperview()
        self.mapView.showMapIcons()
    }
    
    func searchCompleted(coordinates: CLLocationCoordinate2D) {
        let coordRegion = MKCoordinateRegionMakeWithDistance(coordinates, 500, 500)
        map.setRegion(coordRegion, animated: true)
        
        sendDropTouchUpInside(nil)
    }
    
    func zoomOnCoordinates(_ coordinates: CLLocationCoordinate2D, animated: Bool = true) {
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        
        map.setRegion(region, animated: animated)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // If the user hits "Send"
        if(text == "\n") {
            mapView.resetSendDropRing()
            
            textField.resignFirstResponder()
            textField.isHidden = true
            
            navController.pushViewController(SendDropViewController(currentUser: currentUser,
                                                                    coordinates: map.centerCoordinate,
                                                                    text: textView.text ?? "",
                                                                    lockDuration: self.lockDuration), animated: true)
            
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            centerButtonPressed(nil, false)
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
        self.zoomOnCoordinates(pinToZoomOn!.coordinate)
        
        if let typedAnnotation = view.annotation as? TypedPointAnnotation {
            navController.pushViewController(DropViewController(drop: self.drops[typedAnnotation.id], mapViewController: self), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        var i = -1;
        for view in views {
            i += 1;
            if view.annotation is MKUserLocation {
                continue;
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            if let annotation = view.annotation {
                let point: MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
                
                if (!MKMapRectContainsPoint(self.map.visibleMapRect, point)) {
                    continue;
                }
                
                // Animate drop
                let delay = 0.1 * Double(i)
                view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                UIView.animate(withDuration: 0.5, delay: delay, animations: {() -> Void in
                    view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
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
