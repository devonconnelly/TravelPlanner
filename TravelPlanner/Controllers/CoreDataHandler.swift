import Foundation
import UIKit
import CoreData

class CoreDataHandler {
  
  static let shared = CoreDataHandler()
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var context: NSManagedObjectContext?
  
  private init() {
    context = appDelegate.persistentContainer.viewContext
  }
  
  func saveContext() {
    appDelegate.saveContext()
  }
  
    func DestinationConverter(destinationDTO: DestinationDTO) -> Destination {
        let fetchRequest: NSFetchRequest<Destination> = Destination.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", destinationDTO.id)
        
        var destination = Destination(context: (context)!)
        do {
            let results = try context?.fetch(fetchRequest)
                        
            if let existing = results?.first {
                destination = existing
            } else {
                destination.name = destinationDTO.name
                destination.descriptionText = destinationDTO.description
                destination.category = destinationDTO.category
                destination.imageURL = destinationDTO.image
                destination.id = Int32(destinationDTO.id)
                return destination
            }
        } catch {
            print(error.localizedDescription)
        }
        return destination
    }
    
    func insertUser(username: String, password: String, favourites: [Destination]? = [], trips: [Trip]? = [], completion: @escaping () -> Void) {
    let user = User(context: context!)
        user.username = username
        user.password = password
    
    saveContext()
    completion()
}

    func addTrip(to user: User, name: String, startDate: String, travelMode: String, tripDuration: String, destinations: [Destination], completion: @escaping () -> Void) {
            guard let context = context else { return }
            let trip = Trip(context: context)
            trip.name = name
            trip.startDate = startDate
            trip.travelMode = travelMode
            trip.tripDuration = tripDuration
            trip.user = user

            destinations.forEach { trip.addToDestinations($0) }
            user.addToTrips(trip)

            saveContext()
            completion()
        }
    
    func addFavourite(to user: User, destinationDTO: DestinationDTO, completion: @escaping () -> Void) {

        let destination = DestinationConverter(destinationDTO: destinationDTO)

        user.addToFavourites(destination)
            
        saveContext()
        completion()
        
    }
    
    func fetchTrips(for user: User) -> [Trip] {
        if let trips = user.trips as? Set<Trip> {
            return Array(trips)
        } else {
            return []
        }
    }
    
    func fetchDestinationsFromTrip(for trip: Trip) -> [Destination] {
        if let destinations = trip.destinations as? Set<Destination> {
            return Array(destinations)
        } else {
            return []
        }
    }
    
    func fetchFavourites(for user: User) -> [Destination] {
        if let favourites = user.favourites as? Set<Destination> {
            return Array(favourites)
        } else {
            return []
        }
    }
    
    func removeTrip(from user: User, trip: Trip, completion: @escaping () -> Void) {
        user.removeFromTrips(trip)
        saveContext()
        completion()
    }
    
    
    func removeFavourite(from user: User, destination: Destination, completion: @escaping () -> Void) {
        user.removeFromFavourites(destination)
        saveContext()
        completion()
    }
    
    func isFavourite(user: User, destinationId: Int) -> Bool {
        let favourites = fetchFavourites(for: user)
        return favourites.contains { $0.id == destinationId }
    }
    
    func removeDestinationFromTrip(trip: Trip, destination: Destination, completion: @escaping() -> Void) {
        trip.removeFromDestinations(destination)
            
        saveContext()
        completion()
    }
    
    func addDestinationToTrip(trip: Trip, destination: Destination, completion: @escaping () -> Void) {
        trip.addToDestinations(destination)
        
        saveContext()
        completion()
    }
  
  func fetchUserData() -> Array<User> {
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    do {
      let user = try context?.fetch(fetchRequest)
      return user!
    } catch {
      print(error.localizedDescription)
      let user = Array<User>()
      return user
    }
  }
    
  
  func deleteData(for user:User, completion: @escaping () -> Void) {
    
    context!.delete(user)
    saveContext()
    completion()
  }
}
