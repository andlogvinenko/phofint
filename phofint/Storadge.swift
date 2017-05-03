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


class Storadge: NSObject {

    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext){
        self.context = context
        super.init()
    }

    
    func update(fromResource: String, ofType: String){
        
        if let data = loadResource(forResource: "locations", ofType: "json"){
            update(fromJson: data)
        }
    }
    
    func loadResource(forResource: String, ofType: String) -> Data?
    {
        // Update info from stored.json.
        if let fileWithLocation = Bundle.main.path(forResource: forResource, ofType: ofType){
            return NSData(contentsOfFile: fileWithLocation) as Data?
        }
        return nil
    }
    
    func update(fromJson: Data){
        
        // parse JSON
        if let locationDict = try? JSONSerialization.jsonObject(with: fromJson, options: []) as! NSDictionary{
        
            // get updatedDate
            if let updatedDateString = locationDict["updated"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss'Z'"

                if let updatedDate = dateFormatter.date(from: updatedDateString) {
        
                    // getLastUpdatedDate
                    let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date
        
                    if((lastUpdateDate == nil) || (lastUpdateDate! < updatedDate)){
            
                        saveNewDatabase(withList: locationDict, created: updatedDate)
                    }
                }
            }
        }
    }
    
    func saveNewDatabase(withList: NSDictionary, created: Date){
        
        deleteStandardPois()
        
        // Update database
        let dataLocations = withList["locations"] as! [NSDictionary]
        
        for item in dataLocations {
            
            if let lat = item["lat"] as? Double,
                let lng = item["lng"] as? Double,
                let name = item["name"] as? String{

                let poiItem = NSEntityDescription.insertNewObject(forEntityName: "Poi", into: context) as! PoiItem
            
                poiItem.lat = lat
                poiItem.lng = lng
                poiItem.name = name
                poiItem.note = ""
                poiItem.isCustom = false
                poiItem.isChanged = false
            }
            
        }
        
        UserDefaults.standard.setValue(created, forKey: "lastUpdateDate")
        
        saveContext()

    }
    
    func saveContext(){
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error while save contect \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    func deleteStandardPois(){
        
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
        
        saveContext()
    }

    
    func deleteAllPois(){
        
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
                context.delete(record)
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        saveContext()
    }
    
    
    func updateRecord(record: PoiItem?,
                      latitude: Double,
                      longitude: Double,
                      name: String,
                      note: String){
        
        var item: PoiItem
        
        if (record == nil){
            item = (NSEntityDescription.insertNewObject(forEntityName: "Poi", into: context) as! PoiItem)
        }else{
            item = record!
        }
        
        item.lat = latitude
        item.lng = longitude
        item.name = name
        item.note = note
        item.isCustom = true
        item.isChanged = true
        saveContext()
        
    }

    
    func resortPois(location: CLLocationCoordinate2D ){
        
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
                
                let poiLocation = CLLocation(latitude: record.lat, longitude: record.lng)
                    record.distance = poiLocation.distance(from: myLocation);
            }
            
            saveContext()
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
}
