//
//  DestinationDetailsViewController.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//

import UIKit

class DestinationDetailsViewController: UIViewController {

    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var conditionIcon: UIImageView!
    @IBOutlet weak var feelslike: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var destImage: UIImageView!
    var destination: DestinationDTO!
    var weather: WeatherResponse!
    var destinationId: Int!
    var  user: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDestinationDetail()
        user = SessionManager.shared.currentUser
    }
    
    func fetchDestinationDetail() {
        guard let destinationId = destinationId else { return }
        
        ApiHandler.shared.getDestinationByID(id: destinationId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let destination):
                    self.destination = destination
                    self.fetchWeather(destination: destination)
                case .failure(let error):
                    print("Error fetching dest details: \(error)")
                }
            }
        }
    }
    
    func fetchWeather(destination: DestinationDTO) {
        ApiHandler.shared.fetchWeather(for: destination.name) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self.weather = weather
                    self.updateUI()
                case .failure(let error):
                    print("Error fetching weather details: \(error)")
                }
            }
        }
    }
    
    func updateUI() {
        name.text = destination.name
        category.text = destination.category
        descriptionText.text = destination.description
        
        temp.text = "\(weather.current.temp_c)°C"
        feelslike.text = "Feels like \(weather.current.feelslike_c)°C"
        condition.text = weather.current.condition.text
        
        let iconPath = weather.current.condition.icon
            let iconUrlString = iconPath.hasPrefix("http") ? iconPath : "https:\(iconPath)"
            if let imageUrl = URL(string: iconUrlString) {
                URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.conditionIcon.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        
        if let imageUrl = URL(string: destination.image) {
            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.destImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        checkIfFavourite()
    }
    
    func checkIfFavourite() {
        guard let user = user else { return }

        let isAlreadyFavourite = CoreDataHandler.shared.isFavourite(user: user, destinationId: destination.id)

        if isAlreadyFavourite {
            favouriteButton.setTitle("Already in Favourites", for: .normal)
            favouriteButton.isEnabled = false
            favouriteButton.backgroundColor = .lightGray
        } else {
            favouriteButton.setTitle("Add to Favourites", for: .normal)
            favouriteButton.isEnabled = true
        }
    }

    @IBAction func addToFavouritesTapped(_ sender: Any) {
        
        CoreDataHandler.shared.addFavourite(to: user!, destinationDTO: destination) { [weak self] in
                DispatchQueue.main.async {
                    self?.favouriteButton.setTitle("Added to Favourites", for: .normal)
                    self?.favouriteButton.isEnabled = false
                    self?.favouriteButton.backgroundColor = .lightGray
                }
            }
    }
}
