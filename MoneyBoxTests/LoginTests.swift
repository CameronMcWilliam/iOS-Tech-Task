//
//  LoginViewControllerTests.swift
//  MoneyBoxTests
//
//  Created by Zeynep Kara on 18.01.2022.
//

import XCTest
@testable import MoneyBox
@testable import Networking

// MockDataProvider subclassing DataProvider to provide predictable responses for testing
class MockDataProvider: DataProvider {
    override func login(request: LoginRequest, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        // Reads predefined successful login data for testing
        StubData.read(file: "LoginSucceed") { (result: Result<LoginResponse, Error>) in
            completion(result)
        }
    }
    
    override func fetchProducts(completion: @escaping (Result<AccountResponse, Error>) -> Void) {
        // Reads predefined account data for testing
        StubData.read(file: "Accounts") { (result: Result<AccountResponse, Error>) in
            completion(result)
        }
    }
}

class LoginViewControllerTests: XCTestCase {
    
    var loginVC: LoginViewController!
    var dataProvider: MockDataProvider!
    
    override func setUp() {
        super.setUp()
        // Instantiate storyboard and login view controller for testing
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        self.loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        self.dataProvider = MockDataProvider()
        
        // Loads the view hierarchy into memory
        self.loginVC.loadViewIfNeeded()
    }
    
    override func tearDown() {
        // Clean up after test cases
        self.loginVC = nil
        self.dataProvider = nil
        super.tearDown()
    }
    
    // Test case for valid email
    func testValidEmail() {
        let email = "test@example.com"
        XCTAssertTrue(loginVC.isValidEmail(email))
    }
    
    // Test case for invalid email
    func testInvalidEmail() {
        let email = "testexample.com"
        XCTAssertFalse(loginVC.isValidEmail(email))
    }
    
    // Test case for successful login
    func testSuccessfulLogin() {
        let exp = expectation(description: "Waiting for login result")
        
        let dataProvider = MockDataProvider()
        dataProvider.login(request: LoginRequest(email: "test+ios@moneyboxapp.com", password: "password")) { result in
            switch result {
            case .success(let loginResponse):
                // Assert for the expected login response
                XCTAssertNotNil(loginResponse.session.bearerToken)
                XCTAssertEqual(loginResponse.user.firstName, "Michael")
                XCTAssertEqual(loginResponse.user.lastName, "Jordan")
                XCTAssertEqual(loginResponse.session.bearerToken, "GuQfJPpjUyJH10Og+hS9c0ttz4q2ZoOnEQBSBP2eAEs=")
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
            exp.fulfill() // Signal that the expectation has been fulfilled
        }
        
        waitForExpectations(timeout: 5.0) // Wait until the expectation is fulfilled
    }
    
    // Test case for fetching products
    func testFetchProducts() {
        let exp = expectation(description: "Waiting for products result")
        
        dataProvider.fetchProducts() { result in
            switch result {
            case .success(let accountResponse):
                // Assert for the received account data
                if let accountsReceived = accountResponse.accounts {
                    XCTAssertGreaterThan(accountsReceived.count, 0)
                } else {
                    XCTFail("Accounts is nil")
                }
                
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
            exp.fulfill() // Signal that the expectation has been fulfilled
        }
        
        waitForExpectations(timeout: 5.0) // Wait until the expectation is fulfilled
    }
    
}
