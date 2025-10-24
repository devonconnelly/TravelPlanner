//
//  TripListViewController.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//

import UIKit

class TripListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tripTable: UITableView!
    var trips: [Trip] = []
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        tripTable.dataSource = self
        tripTable.delegate = self
        tripTable.separatorStyle = .none
        
        user = SessionManager.shared.currentUser
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchTrips()
    }
    
    func fetchTrips() {
        trips = CoreDataHandler.shared.fetchTrips(for: user)
        tripTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "TripViewCell", for: indexPath) as! TripViewCell
                
        let trip = trips[indexPath.row]
                    
        itemCell.name.text = trip.name
        itemCell.startDate.text = trip.startDate
        itemCell.numDest.text = "\(trip.destinations?.count ?? 0) Destinations"
                
        itemCell.imageView?.image = UIImage(named: "placeholder")
            
        if let destinationSet = trip.destinations as? Set<Destination>,
           let firstDestination = destinationSet.first,
           let imageUrlString = firstDestination.imageURL,
           let imageUrl = URL(string: imageUrlString) {
            
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        itemCell.tripImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        itemCell.tripImage.layer.cornerRadius = 10
        itemCell.tripImage.layer.masksToBounds = true
        itemCell.layer.cornerRadius = 10
        itemCell.layer.masksToBounds = true
        itemCell.selectionStyle = .none
        
        return itemCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 135
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "TripDetailsViewController") as? TripDetailsViewController {
                    detailVC.trip = trips[indexPath.row]
                    detailVC.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(detailVC, animated: true)
            }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
        title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let alert = UIAlertController(title: "Confirm Delete",
                                              message: "Are you sure you want to delete this trip?",
                                              preferredStyle: .alert)
                
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })

            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                let tripToRemove = self.trips[indexPath.row]
                CoreDataHandler.shared.removeTrip(from: self.user, trip: tripToRemove) {
                    self.trips.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    completionHandler(true)
                }
            })
            self.present(alert, animated: true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    @IBAction func createTapped(_ sender: Any) {
        if let createVC = storyboard?.instantiateViewController(withIdentifier: "TripCreateViewController") as? TripCreateViewController {
                createVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(createVC, animated: true)
        }
    }
}
