//
//  SavedDestinationsViewController.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-15.
//

import UIKit

class SavedDestinationsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var favourites: [Destination] = []
    var user: User!
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.dataSource = self
        collectionView.delegate = self
        user = SessionManager.shared.currentUser
        fetchFavorites()
    }
    
    func fetchFavorites() {
        favourites = CoreDataHandler.shared.fetchFavourites(for: user)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favourites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteViewCell", for: indexPath) as! FavouriteViewCell
        let destination = favourites[indexPath.row]
        
        itemCell.name.text = destination.name
        itemCell.name.textColor = .white

        if let imageUrlString = destination.imageURL,
           let imageUrl = URL(string: imageUrlString) {
            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        itemCell.favImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        itemCell.favImage.layer.cornerRadius = 10
        itemCell.favImage.clipsToBounds = true

        itemCell.unfavoriteButtonAction = { [weak self] in
            guard let self = self else { return }
            CoreDataHandler.shared.removeFavourite(from: user, destination: destination) {
                let alert = UIAlertController(title: "Removed", message:"Destination removed from favourites", preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "OK", style:.default))
                self.present(alert, animated: true)
                self.fetchFavorites()
            }
        }

        return itemCell
    }
    



}
