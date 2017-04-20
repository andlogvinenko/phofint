//
//  PinAnnotation.swift
//  phofint
//
//  Created by Andrey Logvinenko on 4/12/17.
//  Copyright © 2017 Epam. All rights reserved.
//

import MapKit

class PinAnnotation: NSObject, MKAnnotation{
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    var record: PoiItem
    
    init (record: PoiItem)
    {
        let coord = CLLocationCoordinate2DMake(record.lat, record.lng)

        self.title = record.name
        self.subtitle = record.note
        self.coordinate = coord
        self.record = record
    }
    
}

