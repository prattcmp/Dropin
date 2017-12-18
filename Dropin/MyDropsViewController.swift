//
//  MyDropsViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 10/26/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import MapKit

class MyDropsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MGSwipeTableCellDelegate, CLLocationManagerDelegate {
    var mapViewController: MapViewController!
    
    var myDropsView: MyDropsView!

    var drops = [Drop]()
    var distances = [Int: String]()
    
    var locManager: CLLocationManager!
    var userLocation: CLLocation!
    
    init(mapViewController: MapViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.mapViewController = mapViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_  animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                currentUser.refreshDrops { (_ isSuccess: Bool) in
                    self.drops = currentUser.drops
                    
                    DispatchQueue.main.async {
                        self.myDropsView.dropTable.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.locManager = CLLocationManager()
        self.locManager.delegate = self
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locManager.requestWhenInUseAuthorization()
        self.locManager.startUpdatingLocation()
        
        myDropsView = MyDropsView()
        myDropsView.dropTable.delegate = self
        myDropsView.dropTable.dataSource = self
        
        // Show the table
        self.view.addSubview(myDropsView)
        
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                currentUser.refreshDrops { (_ isSuccess: Bool) in
                    self.drops = currentUser.drops
                    
                    DispatchQueue.main.async {
                        self.myDropsView.dropTable.reloadData()
                    }
                }
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = manager.location!
        var i = 0
        
        drops.forEach { drop in
            let distance: CLLocationDistance = self.userLocation.distance(from: CLLocation(latitude: drop.coordinates.latitude, longitude: drop.coordinates.longitude))
            self.distances[i] = distance.toPrettyDistance()
            
            i += 1
        }
        
        self.myDropsView.dropTable.reloadData()
    }
    
    // Disables tableview bouncing at the top
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == myDropsView.dropTable {
            let a = scrollView.contentOffset
            if a.y <= 0 {
                scrollView.contentOffset = CGPoint.zero
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drops.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var identifier = "received-box"
        var name = self.drops[indexPath.row].from!.name
        
        if self.drops[indexPath.row].from?.username == currentUser.username {
            identifier = "sent-arrow"
            name = self.drops[indexPath.row].to!.name
        }
        
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        
        cell.textLabel!.text = name
        cell.textLabel!.font = UIFont(name: cell.textLabel!.font.fontName, size: 15)
        cell.detailTextLabel!.text = self.drops[indexPath.row].expires_at.timeAgoSinceNow()
        cell.detailTextLabel!.alpha = 0.5
        
        cell.imageView?.image = UIImage(named: identifier)
        let itemSize = CGSize(width: 17.0, height: 17.0)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, 0.0)
        let imageRect = CGRect(x:0.0, y:0.0, width:itemSize.width, height:itemSize.height)
        cell.imageView?.image!.draw(in:imageRect)
        cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let distance = self.distances[indexPath.row] ?? ""
        
        let label = UILabel()
        label.text = distance
        label.font = cell.detailTextLabel!.font
        label.alpha = 0.5
        label.textAlignment = .right
        label.sizeToFit()
        cell.accessoryView = label
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navController.pushViewController(DropViewController(drop: self.drops[indexPath.row], mapViewController: self.mapViewController), animated: true)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
}

