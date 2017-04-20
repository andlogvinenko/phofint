//
//  PoiListViewController.swift
//  phofint
//
//  Created by Andrey Logvinenko on 4/11/17.
//  Copyright © 2017 Epam. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit


class PoiListViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    
    var locationManager: CLLocationManager!

    
    var fetchedResultsController: NSFetchedResultsController<PoiItem>!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        let location = (locations.last! as CLLocation).coordinate

        print("locations1 = \(locValue.latitude) \(locValue.longitude)")
        print("locations2 = \(location.latitude) \(location.longitude)")
        
        updatePois(coord: location)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //updatePois(coord: nil)
        
//        
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            let fetchError = error as NSError
//            print("\(fetchError), \(fetchError.userInfo)")
//        }
//        tableView.reloadData()
        
        
    }
    
    func updatePois(coord: CLLocationCoordinate2D ){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let updater = Updater(context: appDelegate.persistentContainer.viewContext)
        
        updater.resortPois(location: coord)
//        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        tableView.dataSource = self
        tableView.delegate = self

        let fr:NSFetchRequest<PoiItem> = PoiItem.fetchRequest()
        
//         Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "distance", ascending: true)
        fr.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
    }

    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath as IndexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            }
            break;
        case .update:
            if let ip = indexPath {
                if let cell = tableView.cellForRow(at: ip) as? POICell {
                    configureCell(cell: cell, atIndexPath: indexPath! as NSIndexPath)
                }
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath as IndexPath], with: .fade)
            }
            break;
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "POICell", for: indexPath as IndexPath) as! POICell
        
        // Configure Table View Cell
        configureCell(cell: cell, atIndexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func configureCell(cell: POICell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let record = fetchedResultsController.object(at: indexPath as IndexPath)
        
        cell.titleLabel.text = record.name
        
        var distance = ""
        
        if record.distance<0 {
            distance = ""
        }
        else if record.distance < 1000 {
            distance = "\(String(format: "%.0f",record.distance))m"
        }
        else if record.distance < 20000 {
            distance = "\(String(format: "%.2f",record.distance / 1000))km"
        }
        else if record.distance < 1000000 {
            distance = "\(String(format: "%.0f",record.distance / 1000))km"
        }
        else {
            distance = "\(String(format: "%.1f",record.distance / 1000000))th km"
        }
        
        //let distance = "\(String(format: "%.2f",myLocation.distance(from: location) / 1000))km";
        
        cell.distanceLabel.text = distance
        
        cell.coord = CLLocationCoordinate2D(latitude: record.lat, longitude: record.lng)
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.tabBarController?.selectedIndex = 0
        
        let record = fetchedResultsController.object(at: indexPath as IndexPath)
        
        let navigationController = self.tabBarController?.viewControllers?[0] as! UINavigationController
        
        
        let mapViewController = navigationController.viewControllers[0] as! MapViewController
        
        mapViewController.updateLocation( record: record )
        
    }
    
}
