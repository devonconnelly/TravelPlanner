import UIKit

class TripCreateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var destTable: UITableView!
    
    @IBOutlet weak var addedDestinations: UILabel!
    @IBOutlet weak var tripName: UITextField!
    @IBOutlet weak var travelMode: UIPickerView!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    
    let travelModes = ["Car", "Flight", "Train"]
    
    var destinations: [DestinationDTO] = []
    var addedDestinationsIDS: [Int] = []
    
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        destTable.dataSource = self
        destTable.delegate = self
        travelMode.delegate = self
        travelMode.dataSource = self
        
        destTable.separatorStyle = .none
        user = SessionManager.shared.currentUser
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(saveTapped))
            
        navigationItem.rightBarButtonItem = addButton
        
        fetchDestinations()
    }
    
    func fetchDestinations() {
        ApiHandler.shared.getAllDestinations() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let destinations):
                    self.destinations = destinations
                    self.destTable.reloadData()
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
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let destination = destinations[indexPath.row]
        
        let isAdded = addedDestinationsIDS.contains(destination.id)

        let actionTitle = isAdded ? "Remove" : "Add"
        let actionStyle: UIContextualAction.Style = isAdded ? .destructive : .normal
        
        let action = UIContextualAction(style: actionStyle, title: actionTitle) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            if isAdded {
                if let index = self.addedDestinationsIDS.firstIndex(of: destination.id) {
                    self.addedDestinationsIDS.remove(at: index)
                }
            } else {
                self.addedDestinationsIDS.append(destination.id)
            }
            
            let selectedNames = self.destinations
                .filter { self.addedDestinationsIDS.contains($0.id) }
                .map { $0.name }
                .joined(separator: ", ")

            self.addedDestinations.text = "Destination(s): \(selectedNames)"
            
            self.destTable.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }

        action.backgroundColor = isAdded ? .systemRed : .systemGreen
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            travelModes.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            travelModes[row]
        }
    
    @objc func saveTapped() {
        guard let name = tripName.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Trip name is required.")
            return
        }
                
        if addedDestinationsIDS.isEmpty {
            showAlert(title: "Add Destination", message: "Please select at least one destination.")
            return
        }
                
        let mode = travelModes[travelMode.selectedRow(inComponent: 0)]

        guard endDate.date >= startDate.date else {
            showAlert(title: "Error", message: "End date must be after start date.")
            return
        }
        let selectedDestinations = destinations.filter { addedDestinationsIDS.contains($0.id) }
        
        let coreDataDestinations = selectedDestinations.map { CoreDataHandler.shared.DestinationConverter(destinationDTO: $0) }
        
        let calendar = Calendar.current
        let tripDuration = calendar.dateComponents([.day], from: startDate.date, to: endDate.date).day ?? 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let startDateString = dateFormatter.string(from: startDate.date)
        let tripDurationString = String(tripDuration)
        
        CoreDataHandler.shared.addTrip(to: user, name: name, startDate: startDateString, travelMode: mode, tripDuration: tripDurationString, destinations: coreDataDestinations) {
            self.showAlert(title: "Trip Added", message: "Trip saved successfully!") {
                self.tripName.text = ""
                self.travelMode.selectRow(0, inComponent: 0, animated: true)
                self.startDate.date = Date()
                self.endDate.date = Date()
                self.addedDestinationsIDS.removeAll()
                self.destTable.reloadData()
                self.navigationController?.popViewController(animated: true)
            }
        }
                
        
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true, completion: nil)
    }
}
