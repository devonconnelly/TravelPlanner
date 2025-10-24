//
//  User+CoreDataProperties.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var username: String?
    @NSManaged public var password: String?
    @NSManaged public var favourites: NSSet?
    @NSManaged public var trips: NSSet?

}

// MARK: Generated accessors for favourites
extension User {

    @objc(addFavouritesObject:)
    @NSManaged public func addToFavourites(_ value: Destination)

    @objc(removeFavouritesObject:)
    @NSManaged public func removeFromFavourites(_ value: Destination)

    @objc(addFavourites:)
    @NSManaged public func addToFavourites(_ values: NSSet)

    @objc(removeFavourites:)
    @NSManaged public func removeFromFavourites(_ values: NSSet)

}

// MARK: Generated accessors for trips
extension User {

    @objc(addTripsObject:)
    @NSManaged public func addToTrips(_ value: Trip)

    @objc(removeTripsObject:)
    @NSManaged public func removeFromTrips(_ value: Trip)

    @objc(addTrips:)
    @NSManaged public func addToTrips(_ values: NSSet)

    @objc(removeTrips:)
    @NSManaged public func removeFromTrips(_ values: NSSet)

}

extension User : Identifiable {

}
