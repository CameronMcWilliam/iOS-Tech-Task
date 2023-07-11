//
//  LoginViewController.swift
//  MoneyBox
//
//  Created by Zeynep Kara on 16.01.2022.
//

import UIKit
import Networking

// Struct to encapsulate network data
struct NetworkData {
    var session: SessionManager
    var loginResponse: LoginResponse
    var accountResponse: AccountResponse
}

// Controller for the login view
class LoginViewController: UIViewController {
    
    // Instance of login response
    var loginResponse: LoginResponse?
    
    // User Interface elements linked from the storyboard
    @IBOutlet weak var txtEmailLogin: UITextField!
    @IBOutlet weak var txtPasswordLogin: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var actLogin: UIActivityIndicatorView! // Activity indicator for the login process
    
    // Function to validate email using regular expressions
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Function that is called when the view is about to made visible
    override func viewWillAppear(_ animated: Bool) {
        let session = SessionManager()
        session.removeUserToken() // Remove any existing user tokens before the view appears
    }
    
    // Function to handle the login button pressed event
    @IBAction func buttonPressed(_ sender: UIButton) {
        actLogin.startAnimating() // Start the activity indicator
        
        // Validate email input
        guard let emailValue = txtEmailLogin.text, !emailValue.isEmpty else {
            // Show an alert if email input is empty
            let alert = UIAlertController(title: "Error", message: "Please enter an Email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.actLogin.stopAnimating()
            return
        }
        
        // Check for a valid email
        if !self.isValidEmail(emailValue) {
            // Show an alert if email input is not valid
            let alert = UIAlertController(title: "Error", message: "Please enter a valid email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.actLogin.stopAnimating()
            return
        }
        
        // Validate password input
        guard let passwordValue = txtPasswordLogin.text, !passwordValue.isEmpty else {
            // Show an alert if password input is empty
            let alert = UIAlertController(title: "Error", message: "Please enter a password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.actLogin.stopAnimating()
            return
        }
        
        // Create the login request
        let loginRequest = LoginRequest(email: emailValue, password: passwordValue)
        
        // Create an instance of the data provider for login
        let dataProvider = DataProvider()
        dataProvider.login(request: loginRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loginResponse):
                    let session = SessionManager()
                    session.setUserToken(loginResponse.session.bearerToken) // Set the user token in the session manager
                    
                    // Fetch products and handle the result
                    dataProvider.fetchProducts() { result in
                        switch result {
                        case .success(let accountResponse):
                            // On success, perform the login segue and pass the network data
                            let networkData = NetworkData(session: session, loginResponse: loginResponse, accountResponse: accountResponse)
                            self.performSegue(withIdentifier: "LoginSuccess", sender: networkData)
                            self.actLogin.stopAnimating()
                        case .failure(let error):
                            // Handle the error here
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.actLogin.stopAnimating()
                        }
                    }
                case .failure(let error):
                    // Handle the error here
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.actLogin.stopAnimating()
                }
            }
        }

    }
    
    // Function to prepare for a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSuccess" {
            // If the segue is the "LoginSuccess" segue, set the necessary data on the HomeViewController
            let vcHome = segue.destination as! HomeViewController
            let object = sender as! NetworkData
            vcHome.loginResponse = object.loginResponse
            vcHome.session = object.session
            vcHome.accountResponse = object.accountResponse
        }
    }
    
}
