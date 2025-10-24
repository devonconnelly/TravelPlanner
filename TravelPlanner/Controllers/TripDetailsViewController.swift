//
//  TripDetailsViewController.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//

import UIKit

class TripDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var travelMode: UILabel!
    @IBOutlet weak var tripDuration: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var destinationsTable: UITableView!
    var trip: Trip!
    var destinations: [Destination] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        destinationsTable.delegate = self
        destinationsTable.dataSource = self
        destinationsTable.separatorStyle = .none
        fetchDestinations()
        
        tripName.text = trip.name
        startDate.text = trip.startDate
        tripDuration.text = "\(trip.tripDuration ?? "0") days"
        travelMode.text = trip.travelMode
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDestinationTapped))
            
        navigationItem.rightBarButtonItem = addButton
    }
    
    func fetchDestinations() {
        destinations = CoreDataHandler.shared.fetchDestinationsFromTrip(for: trip)
        destinationsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "DestinationViewCell", for: indexPath) as! DestinationViewCell
                
                let destination = destinations[indexPath.row]
                    
                itemCell.name.text = destination.name
                itemCell.category.text = destination.category
                
        if let imageUrl = URL(string: destination.imageURL!) {
                        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                            if let data = data {
                                DispatchQueue.main.async {
                                    itemCell.destImage.image = UIImage(data: data)
                                }
                            }
                        }.resume()
                    }
                itemCell.destImage.layer.cornerRadius = 10
                itemCell.destImage.layer.masksToBounds = true
                itemCell.layer.cornerRadius = 10
                itemCell.layer.masksToBounds = true
                itemCell.selectionStyle = .none
                
                return itemCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 135
        }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let destinationToRemove = self.destinations[indexPath.row]

            CoreDataHandler.shared.removeDestinationFromTrip(trip: trip, destination: destinationToRemove){
                self.destinations.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                completionHandler(true)
            }
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    @objc func addDestinationTapped() {
        let alert = UIAlertController(title: "Add Destination", message: "Select a destination to add", preferredStyle: .actionSheet)
        let existingDestinationIDs = self.destinations.map { Int($0.id) }
        ApiHandler.shared.getAllDestinations() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let destinations):
                    let filteredDestinations = destinations.filter { !existingDestinationIDs.contains($0.id) }
                    
                    for destination in filteredDestinations {
                        let action = UIAlertAction(title: destination.name, style: .default) { _ in
                            let dest = CoreDataHandler.shared.DestinationConverter(destinationDTO: destination)
                            
                            CoreDataHandler.shared.addDestinationToTrip(trip: self.trip, destination: dest) {
                                self.destinations.append(dest)
                                self.destinationsTable.reloadData()
                            }
                        }
                        alert.addAction(action)
                    }

                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                    self.present(alert, animated: true, completion: nil)
                    
                case .failure(let error):
                    print("Error fetching destinations: \(error.rawValue)")
                }
            }
        }
            
            
            
    }


}
