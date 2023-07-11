//
//  ProductDetailViewController.swift
//  MoneyBox
//  Created by Cameron McWilliam on 08/07/2023.
//

import Foundation
import Networking
import UIKit

// Class representing the detailed view of a product.
class ProductDetailViewController: UIViewController {
    var product: ProductResponse? // The product data will be set before the view controller is presented.
    weak var delegate: RefreshDelegate? // The delegate for refreshing data.

    // Interface builder outlets for UI components.
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPlanValue: UILabel!
    @IBOutlet weak var lblMoneyBox: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var actPayment: UIActivityIndicatorView! // The activity indicator that shows during a payment operation.

    var addValue: Int? // The value to be added to the product.
    var productID: Int? // The ID of the product.
    
    
    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Populates the UI with the received product data.
        if let product = product {
            addValue = product.personalisation?.quickAddDeposit?.amount ?? 0
            productID = product.id ?? 0
            
            lblProductName.text = product.product?.friendlyName
            lblPlanValue.text = "Plan Value: £\(String(product.planValue ?? 0))"
            lblMoneyBox.text = "Moneybox: £\(String(product.moneybox ?? 0))"
            let buttonTitleStr = "Add: £\(addValue ?? 0)"
            let attributedTitle = NSMutableAttributedString(string: buttonTitleStr)

            if let nunitoFont = UIFont(name: "Nunito-Bold", size: 16) {
                attributedTitle.addAttribute(.font, value: nunitoFont, range: NSRange(location: 0, length: buttonTitleStr.count))
                btnAdd.setAttributedTitle(attributedTitle, for: .normal)
            }
        }
    }
    
    // Function that handles the button press action.
    @IBAction func addBtnpressed(_ sender: Any) {
        // Starts the activity indicator and then performs a payment operation.
        actPayment.startAnimating()
        let dataProvider = DataProvider()
        guard let addValue = addValue, let productID = productID else {
            // Handles the case where addValue or productID are nil.
            let alert = UIAlertController(title: "Error", message: "Something went wrong!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            actPayment.stopAnimating()
            return
        }
        let oneOffPayment = OneOffPaymentRequest(amount: addValue, investorProductID: productID)
        dataProvider.addMoney(request: oneOffPayment) { result in
            DispatchQueue.main.async {
                // Handles the result of the payment operation.
                switch result {
                case .success(let paymentResponse):
                    guard let newMoneybox = paymentResponse.moneybox else {
                        return
                    }
                    self.delegate?.refreshData() // Refreshes the data.
                    self.actPayment.stopAnimating() // Stops the activity indicator.
                    self.lblMoneyBox.text = "Moneybox: £\(String(newMoneybox))"
                    let alert = UIAlertController(title: "Deposit successful", message: "New Moneybox Value: £\(String(paymentResponse.moneybox ?? 0))", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                case .failure(let error):
                    // Handles the error.
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.actPayment.stopAnimating() // Stops the activity indicator.
                }
                self.actPayment.stopAnimating() // Stops the activity indicator.
            }
        }
    }
}
