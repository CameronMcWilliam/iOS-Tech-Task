import Foundation
import Networking
import UIKit

class ProductDetailViewController: UIViewController {
    var product: ProductResponse? // This will be set before the view controller is presented

    // Add your IBOutlet variables here. For example:
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPlanValue: UILabel!
    @IBOutlet weak var lblMoneyBox: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Received product: \(product)")

        if let product = product {
            //... your UILabel outlets
            lblProductName.text = product.product?.friendlyName
            lblPlanValue.text = "£\(String(product.planValue ?? 0))"
            lblMoneyBox.text = "Moneybox: \(String(product.moneybox ?? 0))"
        }
    }

}
