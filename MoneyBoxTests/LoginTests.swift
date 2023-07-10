//
//  LoginViewControllerTests.swift
//  MoneyBoxTests
//
//  Created by Zeynep Kara on 18.01.2022.
//

import XCTest
@testable import MoneyBox
@testable import Networking

class MockDataProvider: DataProvider {
    override func login(request: LoginRequest, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        StubData.read(file: "LoginSucceed") { (result: Result<LoginResponse, Error>) in
            completion(result)
        }
    }
    
    override func fetchProducts(completion: @escaping (Result<AccountResponse, Error>) -> Void) {
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
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        self.loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        self.dataProvider = MockDataProvider()
        
        self.loginVC.loadViewIfNeeded()
    }
    
    override func tearDown() {
        self.loginVC = nil
        self.dataProvider = nil
        super.tearDown()
    }
    
    func testValidEmail() {
        let email = "test@example.com"
        XCTAssertTrue(loginVC.isValidEmail(email))
    }
    
    func testInvalidEmail() {
        let email = "testexample.com"
        XCTAssertFalse(loginVC.isValidEmail(email))
    }
    
    func testSuccessfulLogin() {
        let exp = expectation(description: "Waiting for login result")
        
        let dataProvider = MockDataProvider()
        dataProvider.login(request: LoginRequest(email: "test+ios@moneyboxapp.com", password: "password")) { result in
            switch result {
            case .success(let loginResponse):
                XCTAssertNotNil(loginResponse.session.bearerToken)
                XCTAssertEqual(loginResponse.user.firstName, "Michael")
                XCTAssertEqual(loginResponse.user.lastName, "Jordan")
                XCTAssertEqual(loginResponse.session.bearerToken, "GuQfJPpjUyJH10Og+hS9c0ttz4q2ZoOnEQBSBP2eAEs=")
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testFetchProducts() {
        let exp = expectation(description: "Waiting for products result")
        
        dataProvider.fetchProducts() { result in
            switch result {
            case .success(let accountResponse):
                if let accountsReceived = accountResponse.accounts {
                    XCTAssertGreaterThan(accountsReceived.count, 0)
                } else {
                    XCTFail("Accounts is nil")
                }
                
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
    
}
