//
//  LoginViewController.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    private var userArray: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userArray = CoreDataHandler.shared.fetchUserData()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let username = usernameField.text, !username.isEmpty, let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both username and password")
            return
        }
        usernameField.text = ""
        passwordField.text = ""
        if let user = userArray.first(where: { $0.username == username && $0.password == password }) {
            SessionManager.shared.currentUser = user
            navigateToMainTabBar()
        } else {
            CoreDataHandler.shared.insertUser(username: username, password: password) { [weak self] in
                guard let self = self else { return }
                showAlert(title: "Signed Up", message: "Your account has been created successfully") {
                    self.userArray = CoreDataHandler.shared.fetchUserData()
                    if let newUser = self.userArray.first(where: { $0.username == username && $0.password == password }) {
                        SessionManager.shared.currentUser = newUser
                        self.navigateToMainTabBar()
                    }
                }
                
            }
        }
    }
        
    func navigateToMainTabBar() {
        if let tabBarVC = storyboard?.instantiateViewController(withIdentifier:"MainTabBarController") as? UITabBarController {
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as?SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarVC
                sceneDelegate.window?.makeKeyAndVisible()
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

