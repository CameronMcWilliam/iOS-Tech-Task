//
//  HomeViewController.swift
//  MoneyBox
//
//  Created by Cameron McWilliam on 06/07/2023.
//

import Foundation
import UIKit
import Networking

class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPlanValue: UILabel!
    @IBOutlet weak var lblMoneyBox: UILabel!
}

protocol RefreshDelegate: AnyObject {
    func refreshData()
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RefreshDelegate {
    var loginResponse: LoginResponse?
    var accountResponse: AccountResponse?
    var session: SessionManager?
    
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var lblPlanValue: UILabel!
    @IBOutlet weak var productsTableView: UITableView! // Connect this outlet with UITableView in storyboard

    var products: [Product] = [] // This array will store your products
    var productResponses: [ProductResponse] = []
    
    func populateUI() {
        if let loginResponse = self.loginResponse {
           let userFirstName = loginResponse.user.firstName
           let userLastName = loginResponse.user.lastName
           lblWelcome.text = "Hello \(userFirstName ?? "") \(userLastName ?? "")!"
        }

        if let accountResponse = self.accountResponse {
            if let totalPlanValue = accountResponse.totalPlanValue {
                self.lblPlanValue.text = "Total Plan Value: £\(String(totalPlanValue))"
            }
            if let productResponses = accountResponse.productResponses {
                self.productResponses = productResponses
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsTableView.dataSource = self
        productsTableView.delegate = self
        
        populateUI()
        
    }
    
    func refreshData() {
        let dataProvider = DataProvider()
        dataProvider.fetchProducts() { result in
            switch result {
            case .success(let newAccountResponse):
                self.accountResponse = newAccountResponse
                self.populateUI()
                DispatchQueue.main.async {
                    self.productsTableView.reloadData()
                }
            case .failure(let error):
                // Handle the error here
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.performSegue(withIdentifier: "TokenExpired", sender: alert)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = productResponses.count
        print("Number of rows: \(count)")
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        let productResponse = productResponses[indexPath.row]
        cell.lblProductName.text = productResponse.product?.friendlyName
        cell.lblPlanValue.text = "£\(String(productResponse.planValue ?? 0))"
        cell.lblMoneyBox.text = "Moneybox: £\(String(productResponse.moneybox ?? 0))"
        print("Cell for row at \(indexPath.row) created.")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected product: \(productResponses[indexPath.row])")
        performSegue(withIdentifier: "showProductDetail", sender: productResponses[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetail" {
            let vcProductDetail = segue.destination as! ProductDetailViewController
            let object = sender as! ProductResponse
            vcProductDetail.product = object
            vcProductDetail.delegate = self
        }
    }





}
