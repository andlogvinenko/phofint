//
//  Updater.swift
//  phofint
//
//  Created by Andrey Logvinenko on 4/11/17.
//  Copyright © 2017 Epam. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit


class Updater: NSObject {

    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext){
        self.context = context
        super.init()
    }

    func pushNewJsonDatabase(data: Data) throws
    {
        // parse JSON
        let locationDict = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
        
        
        // get updatedDate
        let updatedDateString = locationDict["updated"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let updatedDate = dateFormatter.date(from: updatedDateString)!
        
        // getLastUpdatedDate
        let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date
        
        if((lastUpdateDate == nil) || (lastUpdateDate! < updatedDate))
        {
            
            deleteStandardPois()
            
            // Update database
            let dataLocations = locationDict["locations"] as! [NSDictionary]
        
            for item in dataLocations {
                
                let poiItem = NSEntityDescription.insertNewObject(forEntityName: "Poi", into: context) as! PoiItem
               
                poiItem.lat = item["lat"] as! Double
                poiItem.lng = item["lng"] as! Double
                poiItem.name = item["name"] as? String
                poiItem.note = ""
                poiItem.isCustom = false
                poiItem.isChanged = false
                
            }
            
            UserDefaults.standard.setValue(updatedDate, forKey: "lastUpdateDate")
            
        }

    }
    
    func deleteStandardPois()
    {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Poi", in: context)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try context.fetch(fetchRequest)
            
            for item in result {
                let record = item as! PoiItem
                
                if !record.isCustom{
                    context.delete(record)
                }
               
                print ("deleted: \(record.name!) ")
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

    
    func resortPois(location: CLLocationCoordinate2D )
    {
        
        let myLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Poi", in: context)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try context.fetch(fetchRequest)
            
            for i in result {
                let record = i as! PoiItem
                
                if location != nil {
                    let poiLocation = CLLocation(latitude: record.lat, longitude: record.lng)
                    record.distance = poiLocation.distance(from: myLocation);
                }
                else
                {
                    record.distance = -1
                }
                //print (record)
            }
            
            try context.save()
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

}
