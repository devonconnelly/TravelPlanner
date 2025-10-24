//
//  HomeViewController.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var destinationTable: UITableView!
    var destinations: [DestinationDTO] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        destinationTable.delegate = self
        destinationTable.dataSource = self
        destinationTable.separatorStyle = .none
        fetchDestinations()
    }
    
    func fetchDestinations() {
        ApiHandler.shared.getAllDestinations() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let destinations):
                    self.destinations = destinations
                    self.destinationTable.reloadData()
                case .failure(let error):
                    print("Error fetching destinations: \(error.rawValue)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "DestinationViewCell", for: indexPath) as! DestinationViewCell
                
                let destination = destinations[indexPath.row]
                    
                itemCell.name.text = destination.name
                itemCell.category.text = destination.category
                
        if let imageUrl = URL(string: destination.image) {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "DestinationDetailsViewController") as? DestinationDetailsViewController {
                               detailVC.destinationId = destinations[indexPath.row].id
                               detailVC.hidesBottomBarWhenPushed = true
                               navigationController?.pushViewController(detailVC, animated: true)
                           }
        }
    
    @IBAction func signOutTapped(_ sender: Any) {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier:"LoginViewController") as? LoginViewController {
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as?SceneDelegate {
                sceneDelegate.window?.rootViewController = loginVC
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
}
