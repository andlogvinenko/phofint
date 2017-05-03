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
        
        if let location = locations.last?.coordinate {
            updatePois(coord: location)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func updatePois(coord: CLLocationCoordinate2D ){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let updater = Storadge(context: appDelegate.persistentContainer.viewContext)
        
        updater.resortPois(location: coord)
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
                        configureCell(cell: cell, atIndexPath: indexPath!)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "POICell", for: indexPath)
        
        if let poiCell = cell as? POICell{
            configureCell(cell: poiCell, atIndexPath: indexPath)
        }
        
        return cell
    }
    
    func configureCell(cell: POICell, atIndexPath indexPath: IndexPath) {

        let record = fetchedResultsController.object(at: indexPath)
        
        cell.titleLabel.text = record.name
        
        let utils = Utils()
        let distance = utils.format(distance: record.distance)
        
        cell.distanceLabel.text = distance
        
        cell.coord = CLLocationCoordinate2D(latitude: record.lat, longitude: record.lng)
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.tabBarController?.selectedIndex = 0
        
        let record = fetchedResultsController.object(at: indexPath)
        
        if let navigationController = self.tabBarController?.viewControllers?[0] as? UINavigationController{
        
            if let mapViewController = navigationController.viewControllers[0] as? MapViewController{
        
                mapViewController.updateLocation( record: record )
            }
        }
    }
    
}
