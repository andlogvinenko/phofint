//
//  MapViewController.swift
//  phofint
//
//  Created by Andrey Logvinenko on 4/12/17.
//  Copyright © 2017 Epam. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongTapMap(recognizer:)))
        mapView.addGestureRecognizer(tapRecognizer)
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didLongTapMap(recognizer:UITapGestureRecognizer) {
        
        if recognizer.state != UIGestureRecognizerState.began {
            return
        }
        
        // Get location point.
        let point = recognizer.location(in: self.mapView)
        
        let coord = mapView.convert(point, toCoordinateFrom: mapView)
        
        addNewPoint(location: coord)
    }
    
    func addNewPoint(location: CLLocationCoordinate2D){
        
        
        let detailController = self.storyboard?.instantiateViewController(withIdentifier: "details") as! DetailedViewController
        
        detailController.coord = location
        detailController.record = nil
        
        self.navigationController?.pushViewController(detailController, animated: true)

    }
    
    func editPoint(annotation: PinAnnotation){
        let detailController = self.storyboard?.instantiateViewController(withIdentifier: "details") as! DetailedViewController
        
        let record = annotation.record

        detailController.coord = annotation.coordinate
        detailController.record = record
        
        self.navigationController?.pushViewController(detailController, animated: true)

    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let context = appDelegate.persistentContainer.viewContext
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Poi", in: context)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            mapView.removeAnnotations(mapView.annotations)
            
            let result = try context.fetch(fetchRequest)
            
            for item in result {
                
                let record = item as! PoiItem
                
                let pin = PinAnnotation(record: record)

                mapView.addAnnotation(pin)
                
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

        
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "map") as? MKPinAnnotationView
        if(view == nil) {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "map")
        }
        
            if let pinAnnotation = annotation as? PinAnnotation{
                
                if(pinAnnotation.record.isCustom){
                    view?.pinTintColor = UIColor.blue
                }else{
                    view?.pinTintColor = UIColor.green
                }
                view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                view?.canShowCallout = true
                view?.animatesDrop = false


            } else
            {
                if annotation is MKUserLocation{
                
                    view?.pinTintColor = UIColor.red
                    view?.animatesDrop = true
                    view?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
                    view?.canShowCallout = true
                }
            }
        
        view?.annotation = annotation

        return view
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? PinAnnotation{
            
            editPoint(annotation: annotation)
            
        }else
            if let userLocation = view.annotation as? MKUserLocation
            {
                // If current location - add new pin.
                let coord = userLocation.coordinate
                addNewPoint(location: coord)
            }
        
    }
    
    
    public func updateLocation(record: PoiItem){
        
        let location = CLLocationCoordinate2D(latitude: record.lat, longitude: record.lng)
        
        let span = MKCoordinateSpanMake(0.1, 0.1)
        
        let region = MKCoordinateRegion (center:  location, span: span)
        
        mapView.setRegion(region, animated: true)
    }

}
