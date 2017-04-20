//
//  PoiItem+CoreDataProperties.swift
//  phofint
//
//  Created by Andrey Logvinenko on 4/11/17.
//  Copyright © 2017 Epam. All rights reserved.
//

import Foundation
import CoreData


extension PoiItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PoiItem> {
        return NSFetchRequest<PoiItem>(entityName: "Poi")
    }

    @NSManaged public var distance: Double
    @NSManaged public var isChanged: Bool
    @NSManaged public var isCustom: Bool
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var name: String?
    @NSManaged public var note: String?

}
