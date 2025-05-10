//
//  Login_HubUITests.swift
//  Login HubUITests
//
//  Created by Sabir Alizada on 22.03.25.
//

import XCTest

final class Login_HubUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = XCUIApplication()
                app.launch()
                
                let exists = NSPredicate(format: "exists == true")
                let launchExpectation = expectation(for: exists, evaluatedWith: app, handler: nil)
                
                wait(for: [launchExpectation], timeout: 5.0)
            }
        }
    }
}
