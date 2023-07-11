//
//  HomeViewController.swift
//  MoneyBox
//  Created by Cameron McWilliam on 06/07/2023.
//

import Foundation
import UIKit
import Networking

// Custom UITableViewCell class for the products list.
class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPlanValue: UILabel!
    @IBOutlet weak var lblMoneyBox: UILabel!
    
    // Overrides layoutSubviews to add an inset to the cell's content.
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}

// Protocol to enable data refreshing from child to parent view controller.
protocol RefreshDelegate: AnyObject {
    func refreshData()
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RefreshDelegate {
    var loginResponse: LoginResponse?
    var accountResponse: AccountResponse?
    var session: SessionManager?
    
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var lblPlanValue: UILabel!
    @IBOutlet weak var productsTableView: UITableView! // Outlet for the UITableView in the storyboard.

    var productResponses: [ProductResponse] = []
    
    // Function to populate the UI with data.
    func populateUI() {
        // Fills the welcome label with the user's first and last names.
        if let loginResponse = self.loginResponse {
            let userFirstName = loginResponse.user.firstName
            let userLastName = loginResponse.user.lastName
            lblWelcome.text = "Hello \(userFirstName ?? "") \(userLastName ?? "")!"
        }

        // Fills the plan value label and the products list with the fetched data.
        if let accountResponse = self.accountResponse {
            if let totalPlanValue = accountResponse.totalPlanValue {
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
                let formattedPlanValue = formatter.string(from: NSNumber(value: totalPlanValue))
                self.lblPlanValue.text = "Total Plan Value: £\(formattedPlanValue ?? "0.00")"
            }
            if let productResponses = accountResponse.productResponses {
                self.productResponses = productResponses
            }
        }
    }
    
    // Function called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate and data source for the UITableView.
        productsTableView.dataSource = self
        productsTableView.delegate = self
        
        // Call the populateUI() function.
        populateUI()
    }
    
    // Function to refresh the data.
    func refreshData() {
        // Fetch the products again and refresh the UITableView.
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
    
    // UITableView functions.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productResponses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a cell and fill it with the product's data.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let productResponse = productResponses[indexPath.row]
        cell.lblProductName.text = productResponse.product?.friendlyName
        let formattedPlanValue = formatter.string(from: NSNumber(value: productResponse.planValue ?? 0.00))
        cell.lblPlanValue.text = "Plan Value: £\(formattedPlanValue ?? "0.00")"
        let formattedMoneyBox = formatter.string(from: NSNumber(value: productResponse.moneybox ?? 0.00))
        cell.lblMoneyBox.text = "Moneybox: £\(formattedMoneyBox ?? "0.00")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Performs a segue to the product detail view when a product cell is selected.
        performSegue(withIdentifier: "showProductDetail", sender: productResponses[indexPath.row])
    }
    
    // Function called before a segue is performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetail" {
            let vcProductDetail = segue.destination as! ProductDetailViewController
            let object = sender as! ProductResponse
            vcProductDetail.product = object
            vcProductDetail.delegate = self
        }
    }
}
