//
//  Trip+CoreDataProperties.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//
//

import Foundation
import CoreData


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var name: String?
    @NSManaged public var startDate: String?
    @NSManaged public var travelMode: String?
    @NSManaged public var tripDuration: String?
    @NSManaged public var user: User?
    @NSManaged public var destinations: NSSet?

}

// MARK: Generated accessors for destinations
extension Trip {

    @objc(addDestinationsObject:)
    @NSManaged public func addToDestinations(_ value: Destination)

    @objc(removeDestinationsObject:)
    @NSManaged public func removeFromDestinations(_ value: Destination)

    @objc(addDestinations:)
    @NSManaged public func addToDestinations(_ values: NSSet)

    @objc(removeDestinations:)
    @NSManaged public func removeFromDestinations(_ values: NSSet)

}

extension Trip : Identifiable {

}
