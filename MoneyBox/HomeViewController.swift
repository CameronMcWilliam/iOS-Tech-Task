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

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var loginResponse: LoginResponse?
    var accountResponse: AccountResponse?
    var session: SessionManager?
    
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var lblPlanValue: UILabel!
    @IBOutlet weak var productsTableView: UITableView! // Connect this outlet with UITableView in storyboard

    var products: [Product] = [] // This array will store your products
    var productResponses: [ProductResponse] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsTableView.dataSource = self
        productsTableView.delegate = self

        if let loginResponse = self.loginResponse {
           let userFirstName = loginResponse.user.firstName
           let userLastName = loginResponse.user.lastName
           lblWelcome.text = "Hello \(userFirstName ?? "") \(userLastName ?? "")!"
        }

        if let accountResponse {
            if let totalPlanValue = accountResponse.totalPlanValue {
                self.lblPlanValue.text = "Total Plan Value: £\(String(totalPlanValue))"
            }
            if let productResponses = accountResponse.productResponses {
                for productResponse in productResponses {
                    self.productResponses.append(productResponse)
                }
//                DispatchQueue.main.async {
//                    self.productsTableView.reloadData()
//                }
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
        cell.lblMoneyBox.text = "Moneybox: \(String(productResponse.moneybox ?? 0))"
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
        }
    }





}
