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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.storadge?.updateRecord(
            record: record,
            latitude: coord.latitude,
            longitude: coord.longitude,
            name: inputTitle.text ?? "",
            note: inputNote.text
        )
        
        self.navigationController?.popViewController(animated: true)
    }


}
