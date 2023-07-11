//
//  HomeTests.swift
//  MoneyBoxTests
//
//  Created by Cameron McWilliam on 10.07.2023.
//

@testable import MoneyBox
import Networking
import XCTest

// Define HomeViewControllerTests class to implement unit tests for the HomeViewController
class HomeViewControllerTests: XCTestCase {
    var homeVC: HomeViewController!
    var mockDataProvider: MockDataProvider!

    // SetUp method that is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()
        // Initialize HomeViewController and MockDataProvider
        homeVC = HomeViewController()
        mockDataProvider = MockDataProvider()
        
        // Instantiate storyboard and home view controller for testing
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        self.homeVC = storyboard.instantiateViewController(withIdentifier: "home") as? HomeViewController
        
        // Loads the view hierarchy into memory
        self.homeVC.loadViewIfNeeded()
        
        // Get login and product data for the test user
        let dataProvider = MockDataProvider()
        dataProvider.login(request: LoginRequest(email: "test+ios@moneyboxapp.com", password: "password")) { result in
            switch result {
            case .success(let loginResponse):
                // Set the loginResponse to use in the HomeViewController
                self.homeVC.loginResponse = loginResponse
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
            dataProvider.fetchProducts() { result in
                switch result {
                case .success(let accountResponse):
                    // Set the accountResponse to use in the HomeViewController
                    self.homeVC.accountResponse = accountResponse
                case .failure(let error):
                    XCTFail("Expected success, got \(error) instead")
                }
            }
        }
        // Loads the view hierarchy into memory and populates UI with user data
        self.homeVC.loadViewIfNeeded()
        self.homeVC.populateUI()
    }
    
    // tearDown method that is called after the invocation of each test method in the class
    override func tearDown() {
        // Clean up after test cases
        self.homeVC = nil
        mockDataProvider = nil
        super.tearDown()
    }

    // Test case for populateUI method
    func testPopulateUI() {
        // Validate if the UI elements are populated with expected user data
        XCTAssertEqual(self.homeVC.lblWelcome.text, "Hello Michael Jordan!")
        XCTAssertEqual(self.homeVC.lblPlanValue.text, "Total Plan Value: £15707.08")
    }

    // Test case for tableView:numberOfRowsInSection method
    func testTableViewNumberOfRows() {
        // Validate if the number of rows in the table view is as expected
        let count = self.homeVC.tableView(self.homeVC.productsTableView, numberOfRowsInSection: 0)
        XCTAssertEqual(count, 2)
    }


    // Test case for tableView:cellForRowAtIndexPath method
    func testTableViewCellForRowAt() {
        // Get the table view cell for the first row
        let cell = self.homeVC.tableView(self.homeVC.productsTableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! ProductTableViewCell

        // Validate if the cell is populated with expected product data
        XCTAssertEqual(cell.lblProductName.text, "Stocks & Shares ISA")
        XCTAssertEqual(cell.lblPlanValue.text, "Plan Value: £10526.09")
        XCTAssertEqual(cell.lblMoneyBox.text, "Moneybox: £570.00")
    }
}
