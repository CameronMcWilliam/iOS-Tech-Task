import Foundation
import Networking
import UIKit

class ProductDetailViewController: UIViewController {
    var product: ProductResponse? // This will be set before the view controller is presented
    weak var delegate: RefreshDelegate?

    // Add your IBOutlet variables here. For example:
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPlanValue: UILabel!
    @IBOutlet weak var lblMoneyBox: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    var addValue: Int?
    var productID: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Received product: \(String(describing: product))")

        if let product = product {
            addValue = product.personalisation?.quickAddDeposit?.amount ?? 0
            productID = product.id ?? 0
            
            lblProductName.text = product.product?.friendlyName
            lblPlanValue.text = "£\(String(product.planValue ?? 0))"
            lblMoneyBox.text = "Moneybox: £\(String(product.moneybox ?? 0))"
            btnAdd.setTitle("Add: £\(addValue ?? 0)", for: .normal)
        }
    }
    @IBAction func addBtnpressed(_ sender: Any) {
        let dataProvider = DataProvider()
        guard let addValue = addValue, let productID = productID else {
            // Handle the error here
            let alert = UIAlertController(title: "Error", message: "Something went wrong!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let oneOffPayment = OneOffPaymentRequest(amount: addValue, investorProductID: productID)
        dataProvider.addMoney(request: oneOffPayment) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentResponse):
                    guard let newMoneybox = paymentResponse.moneybox else {
                        return
                    }
                    self.delegate?.refreshData()
                    self.lblMoneyBox.text = "Moneybox: £\(String(newMoneybox))"
                    let alert = UIAlertController(title: "Deposit successful", message: "New Moneybox Value: £\(String(paymentResponse.moneybox ?? 0))", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                case .failure(let error):
                    // Handle the error here
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}
