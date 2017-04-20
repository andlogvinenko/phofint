//
//  DetailedViewController.swift
//  phofint
//
//  Created by Andrey Logvinenko on 4/12/17.
//  Copyright © 2017 Epam. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailedViewController: UIViewController {

    @IBOutlet var detailedView: UIView!
    @IBOutlet weak var inputTitle: UITextField!
    @IBOutlet weak var inputNote: UITextView!
    @IBOutlet weak var lableLat: UILabel!
    @IBOutlet weak var lableLng: UILabel!
    
    var coord : CLLocationCoordinate2D!
    var record: PoiItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lableLat.text = String(format: "%.6f",(coord?.latitude)!)
        lableLng.text = String(format: "%.6f",(coord?.longitude)!)


        inputNote.text = record?.note
        inputTitle.text = record?.name
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAction))
        
    }
    
    func saveAction(){
        print("Do Back!")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        if( record == nil ){
            record = (NSEntityDescription.insertNewObject(forEntityName: "Poi", into: context) as! PoiItem)
        }

        let poiItem = record!
        
        poiItem.lat = coord.latitude
        poiItem.lng = coord.longitude
        poiItem.name = inputTitle.text
        poiItem.note = inputNote.text
        poiItem.isCustom = true
        poiItem.isChanged = false
        
        appDelegate.saveContext()
        
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
