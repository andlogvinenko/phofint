//
//  phofintTests.swift
//  phofintTests
//
//  Created by Andrey Logvinenko on 4/12/17.
//  Copyright © 2017 Epam. All rights reserved.
//

import XCTest
import UIKit
import CoreData
import CoreLocation
import MapKit

@testable import phofint

class phofintTests: XCTestCase {
    
    var storadge: Storadge!
    
    let resource = "locations"
    let resourceType = "json"
    
    override func setUp() {
        super.setUp()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.storadge = Storadge(context: appDelegate.persistentContainer.viewContext)

    }
    
    override func tearDown() {

        super.tearDown()
    }
    
    func testForLoadingRecources() {
        
        // Test for load resource.
        let json = storadge.loadResource(forResource: resource,ofType: resourceType)
        
        XCTAssertNotNil(json, "Resource not loaded.")
        
        if(json != nil)
        {
            // Check for resource is correct.

            let testBundle = Bundle(for: type(of: self ))

            if let fileWithLocation = testBundle.path(forResource: resource,ofType: resourceType){
                let data = NSData(contentsOfFile: fileWithLocation) as Data?
            
                XCTAssertTrue((data?.elementsEqual(json!))!, "Resource not equals.")
            } else {
                XCTFail( "Test broken, test internal resource not loaded.")
            }
        }
    }
    
    
    func setZeroState(){
        let properyName = "lastUpdateDate"
        
        let created = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(created, forKey: properyName)
        
        storadge.deleteAllPois()
        
        XCTAssertEqual(countRecordInDB(), 0, "Can't delete all records in database.")

    }
    
    
    func testForCorrectUpdateFromZeroState() {
        
        setZeroState()
        
        if let data = loadResource(forResource: "locations", ofType: "json"){
            storadge.update(fromJson: data)
        }

        XCTAssertEqual(countRecordInDB(), 8, "Can't update database.")
        
        let snapShort0 = createShapShotDB()
        
        if let data = loadResource(forResource: "locations", ofType: "json"){
            storadge.update(fromJson: data)
        }

        let snapShort1 = createShapShotDB()
        
        XCTAssertEqual(snapShort0, snapShort1, "Second update broke database.")

    }

    
    func testForCorrectUpdateFromPreviousDate() {
        
        setZeroState()

        let properyName = "lastUpdateDate"
        
        let created = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(created, forKey: properyName)
        
        XCTAssertEqual(countRecordInDB(), 0, "Can't delete all records in database.")
        
        if let data = loadResource(forResource: "locations", ofType: "json"){
            storadge.update(fromJson: data)
        }
        
        XCTAssertEqual(countRecordInDB(), 8, "Can't update database.")
        
    }

    func testForCorrectUpdateForDifferenDates() {
        
        
        setZeroState()
        
        if let data = loadResource(forResource: "locations", ofType: "json"){
            storadge.update(fromJson: data)
        }
        
        XCTAssertEqual(countRecordInDB(), 8, "Can't update database.")
        
        let snapShort0 = createShapShotDB()
        

        
        if let data = loadResource(forResource: "locations_pdate", ofType: "json"){
            storadge.update(fromJson: data)
        }

        XCTAssertEqual(countRecordInDB(), 8, "Can't update database.")
        
        let snapShort1 = createShapShotDB()
        
        XCTAssertEqual(snapShort0, snapShort1, "Wrong update with previous date.")

        
        
        if let data = loadResource(forResource: "locations_sdate", ofType: "json"){
            storadge.update(fromJson: data)
        }
        
        XCTAssertEqual(countRecordInDB(), 6, "Can't update database.")
        
        let snapShort2 = createShapShotDB()
        
        XCTAssertNotEqual(snapShort2, snapShort1, "Wrong update with previous date.")

        
        
        if let data = loadResource(forResource: "locations", ofType: "json"){
            storadge.update(fromJson: data)
        }
        
        XCTAssertEqual(countRecordInDB(), 6, "Can't update database.")

        let snapShort3 = createShapShotDB()
        
        XCTAssertEqual(snapShort2, snapShort3, "Wrong update with second date.")
        
    }
    
    
    func testForCorrectReOrder() {
        
        setZeroState()
        
        if let data = loadResource(forResource: "locations", ofType: "json"){
            storadge.update(fromJson: data)
        }
        
        XCTAssertEqual(countRecordInDB(), 8, "Can't update database.")
        
        let snapShort0 = createShapShotDB()
        
        
        storadge.resortPois(location: CLLocationCoordinate2D(latitude: 0.0,longitude: 0.0))
        
        let snapShort1 = createShapShotDB()
        
        XCTAssertNotEqual(snapShort0, snapShort1, "Wrong reorder operation.")

        storadge.resortPois(location: CLLocationCoordinate2D(latitude: 10.0,longitude: 10.0))
        
        let snapShort2 = createShapShotDB()
        
        XCTAssertNotEqual(snapShort2, snapShort1, "Wrong reorder operation.")

        storadge.resortPois(location: CLLocationCoordinate2D(latitude: 0.0,longitude: 0.0))
        
        let snapShort3 = createShapShotDB()
        
        XCTAssertEqual(snapShort3, snapShort1, "Wrong reorder operation.")

    }
    

    
    func loadResource(forResource: String, ofType: String) -> Data?
    {
         let testBundle = Bundle(for: type(of: self ))
        // Update info from stored.json.
        if let fileWithLocation = testBundle.path(forResource: forResource, ofType: ofType){
            return NSData(contentsOfFile: fileWithLocation) as Data?
        }
        return nil
    }
    
    // Make snapshort like a Json
    func createShapShotDB() -> String?{
        
        var snapShot = "{\n    \"locations\": ["
        let spaces = "       "
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Poi", in: storadge.context)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try storadge.context.fetch(fetchRequest)
            
            for item in result {
                
                let record = item as! PoiItem
                
                snapShot += spaces + "{\n"
                snapShot += spaces + "\"title\": " + (record.name ?? "Nill###########") + "\n"
                snapShot += spaces + "\"note\": " + (record.note ?? "Nill###########") + "\n"
                snapShot += spaces + "\"lat\": \(record.lat)\n"
                snapShot += spaces + "\"lng\": \(record.lng)\n"
                snapShot += spaces + "\"dist\": \(record.distance)\n"
                snapShot += spaces + "},\n"
                
            }
            snapShot += spaces + "]\n"

            return snapShot
            
        } catch {
            XCTFail("Test broken, have no access to DB.")
        }
        return nil;
        
    }

    // Make snapshort like a Json
    func isDBSorted() -> Bool?{
        
        var prevValue = -1.0
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Poi", in: storadge.context)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try storadge.context.fetch(fetchRequest)
            
            for item in result {
                
                let record = item as! PoiItem
                
                if(record.distance < prevValue){
                    return false
                }
                
                prevValue = record.distance
            }
            return true
            
        } catch {
            XCTAssertTrue( false, "Test broken, have no access to DB.")
        }
        return nil;
        
    }

    
    // Make snapshort like a Json
    func countRecordInDB() -> Int?{
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Poi", in: storadge.context)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try storadge.context.fetch(fetchRequest)
            
            return result.count
            
        } catch {
            XCTAssertTrue( false, "Test broken, have no access to DB.")
        }
        return nil;
        
    }



    func assertDistance(dist: Double, text: String){
        
        let formated = Utils().format(distance: dist)
        
        XCTAssertTrue(formated==text,
                      "Distance \(dist) not correct dyspayed as \(formated), but need \(text).")
    }
    
    
    func testFormatDistance() {
        
        assertDistance(dist: 1, text: "1m")
        assertDistance(dist: 100, text: "100m")
        assertDistance(dist: 999, text: "999m")
        assertDistance(dist: 1000, text: "1.00km")
        assertDistance(dist: 1234, text: "1.23km")
        assertDistance(dist: 19994, text: "19.99km")
        assertDistance(dist: 19999, text: "20.00km")
        assertDistance(dist: 20000, text: "20km")
        assertDistance(dist: 1000000, text: "1.0th km")
        
    }

    
}


