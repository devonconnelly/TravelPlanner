//
//  Destination+CoreDataProperties.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//
//

import Foundation
import CoreData


extension Destination {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Destination> {
        return NSFetchRequest<Destination>(entityName: "Destination")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var id: Int32

}

extension Destination : Identifiable {

}
