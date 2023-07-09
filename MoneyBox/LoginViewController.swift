//
//  LoginViewController.swift
//  MoneyBox
//
//  Created by Zeynep Kara on 16.01.2022.
//

import UIKit
import Networking

struct NetworkData {
    var session: SessionManager
    var loginResponse: LoginResponse
    var accountResponse: AccountResponse
}

class LoginViewController: UIViewController {
    
    // loginResponse
    var loginResponse: LoginResponse?
    
    // Storyboard Interface Builder elements
    
    @IBOutlet weak var txtEmailLogin: UITextField!
    @IBOutlet weak var txtPasswordLogin: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var actLogin: UIActivityIndicatorView!
    
    // Utility function
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        actLogin.startAnimating()
        
        // Get the value in the email text field
        guard let emailValue = txtEmailLogin.text, !emailValue.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter an Email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.actLogin.stopAnimating()
            return
        }
        
        if !self.isValidEmail(emailValue) {
            let alert = UIAlertController(title: "Error", message: "Please enter a valid email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.actLogin.stopAnimating()
            return
        }
        
        // Get the value in the password text field
        guard let passwordValue = txtPasswordLogin.text, !passwordValue.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter a password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.actLogin.stopAnimating()
            return
        }
        
        let loginRequest = LoginRequest(email: emailValue, password: passwordValue)
        // Data provider used for login
        let dataProvider = DataProvider()
        dataProvider.login(request: loginRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loginResponse):
                    let session = SessionManager()
                    session.setUserToken(loginResponse.session.bearerToken)
                    dataProvider.fetchProducts() { result in
                        switch result {
                        case .success(let accountResponse):
                            let networkData = NetworkData(session: session, loginResponse: loginResponse, accountResponse: accountResponse)
                            self.performSegue(withIdentifier: "LoginSuccess", sender: networkData)
                        case .failure(let error):
                            // Handle the error here
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                case .failure(let error):
                    // Handle the error here
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            self.actLogin.stopAnimating()
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSuccess" {
            let vcHome = segue.destination as! HomeViewController
            let object = sender as! NetworkData
            vcHome.loginResponse = object.loginResponse
            vcHome.session = object.session
            vcHome.accountResponse = object.accountResponse
        }
    }
    
}
