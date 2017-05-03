//
//  Utils.swift
//  phofint
//
//  Created by Andrey Logvinenko on 5/2/17.
//  Copyright © 2017 Epam. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import MapKit


class Utils {

    func format(distance: Double)->String{
        
        if distance<0 {
            return ""
        }
        else if distance < 1000 {
            return "\(String(format: "%.0f", distance))m"
        }
        else if distance < 20000 {
            return "\(String(format: "%.2f", distance / 1000))km"
        }
        else if distance < 1000000 {
            return "\(String(format: "%.0f", distance / 1000))km"
        }
        else {
            return "\(String(format: "%.1f", distance / 1000000))th km"
        }
    }
}
