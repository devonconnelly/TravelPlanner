//
//  RegisterViewController.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        navigationItem.hidesBackButton = true
    }

    @IBAction func loginTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        guard let username = usernameField.text, !username.isEmpty, let password = passwordField.text, !password.isEmpty else {
                showAlert(message: "Please enter both username and password")
                return
        }
        CoreDataHandler.shared.insertUser(username: username, password: password) { [weak self] in
                       self?.navigationController?.popViewController(animated: true)
                   }
    }
    
    func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
}
