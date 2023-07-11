//
//  ProductDetailTests.swift
//  MoneyBoxTests
//
//  Created by Cameron McWilliam on 11.07.2023.
//

@testable import MoneyBox
import Networking
import XCTest

// Define ProductDetailViewControllerTests class to implement unit tests for the ProductDetailViewController
class ProductDetailViewControllerTests: XCTestCase {
    var productDetailVC: ProductDetailViewController!
    var mockDataProvider: MockDataProvider!
    var loginResponse: LoginResponse!

    // SetUp method that is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()
        // Initialize ProductDetailViewController and MockDataProvider
        productDetailVC = ProductDetailViewController()
        mockDataProvider = MockDataProvider()
        
        // Instantiate storyboard and product detail view controller for testing
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        self.productDetailVC = storyboard.instantiateViewController(withIdentifier: "productDetail") as? ProductDetailViewController
        
        // Loads the view hierarchy into memory
        self.productDetailVC.loadViewIfNeeded()
        
        // Get login and product data for the test user
        let dataProvider = MockDataProvider()
        dataProvider.login(request: LoginRequest(email: "test+ios@moneyboxapp.com", password: "password")) { result in
            switch result {
            case .success(let loginResponseResult):
                // Set the loginResponse to use in the ProductDetailViewController
                self.loginResponse = loginResponseResult
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
            dataProvider.fetchProducts() { result in
                switch result {
                case .success(let accountResponse):
                    // Set the first product of the account to the ProductDetailViewController
                    self.productDetailVC.product = accountResponse.productResponses?[0]
                    // Call viewDidLoad to load product detail view
                    self.productDetailVC.viewDidLoad()
                case .failure(let error):
                    XCTFail("Expected success, got \(error) instead")
                }
            }
        }
        // Loads the view hierarchy into memory again after setting up data
        self.productDetailVC.loadViewIfNeeded()
    }
    
    // tearDown method that is called after the invocation of each test method in the class
    override func tearDown() {
        // Clean up after test cases
        self.productDetailVC = nil
        mockDataProvider = nil
        super.tearDown()
    }

    // Test case for populateUI method
    func testPopulateUI() {
        let productResponse = productDetailVC.product
        // Validate if the UI elements are populated with expected product data
        XCTAssertEqual(self.productDetailVC.lblProductName.text, "Stocks & Shares ISA")
        XCTAssertEqual(self.productDetailVC.lblPlanValue.text, "Plan Value: £\(String(productResponse?.planValue ?? 0))")
        XCTAssertEqual(self.productDetailVC.lblMoneyBox.text, "Moneybox: £\(String(productResponse?.moneybox ?? 0))")
    }

    // Test case for addMoney method when the add money button is pressed
    func testButtonPressAddsMoney() {
        // Attempt to add money to the user's account
        mockDataProvider.addMoney(request: OneOffPaymentRequest(amount: 10, investorProductID: 1)) { result in
            switch result {
            case .success(let paymentResponse):
                // Validate if the new moneybox value is as expected after adding money
                XCTAssertEqual(self.productDetailVC.lblMoneyBox.text, "Moneybox: £\(String(paymentResponse.moneybox ?? 0))")
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
        }
    }
}
