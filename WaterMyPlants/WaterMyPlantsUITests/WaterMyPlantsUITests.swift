//
//  WaterMyPlantsUITests.swift
//  WaterMyPlantsUITests
//
//  Created by Shawn James on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import XCTest

class WaterMyPlantsUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["UITesting"]
        app.launch()
    }
    
    //MARK: - View Identifiers
    enum Identifier: String {
        case userNameTextField = "OnboardVC.UsernameTextField"
        case phoneNumberTextField = "OnboardVC.PhoneNuberTextField"
        case passwordTextField = "OnboardVC.PasswordTextField"
        case signInButton = "OnboardVC.SignInButton"
        case topCVImageView = "WaterTodayScene.TopCollectionViewImage"
        case bottomCVImageView = "WaterTodayScene.BottomCollectionViewImage"
        case bottomCVNameLabel = "WaterTodayScene.BottomCollectionViewNameLabel"
        case uploadImageButton = "CreatePlantVC.UploadImageButton"
        case removeThisImageButton = "CreatePlantVC.RemoveImageButton"
        case doneCreatingPlantButton = "CreateVC.DoneCreatingPlantButton"
        case cancelPlantButton = "CreateVC.CancelButton"
    }
    
    //MARK: - Private
    
    
    // == Funcs
    
    private func textField(identifier: Identifier) -> XCUIElement {
        return app.textFields[identifier.rawValue]
    }
    
    private func textView(identifier: Identifier) -> XCUIElement {
        return app.textViews[identifier.rawValue]
    }
    
    private func buttons(identifier: Identifier) -> XCUIElement {
        return app.buttons[identifier.rawValue]
    }
    
    private func images(identifier: Identifier) -> XCUIElement {
        return app.images[identifier.rawValue]
    }
    
    // == Properties
    
    private var app: XCUIApplication {
        return XCUIApplication()
    }
    
    private var userNameTextField: XCUIElement {
        return textField(identifier: .userNameTextField)
    }
    
    private var passwordTextField: XCUIElement {
        return textField(identifier: .passwordTextField)
    }
    
    private var phoneNumberTextField: XCUIElement {
        return textField(identifier: .phoneNumberTextField)
    }
    
    private var signInButton: XCUIElement {
        return buttons(identifier: .signInButton)
    }
    
    private var topCVImage: XCUIElement {
        return images(identifier: .topCVImageView)
    }
    
    private var bottomCVImage: XCUIElement {
        return images(identifier: .bottomCVImageView)
    }
    
    private var bottomCVName: XCUIElement {
        return textView(identifier: .bottomCVNameLabel)
    }
    
    private var uploadImageButton: XCUIElement {
        return buttons(identifier: .uploadImageButton)
    }
    
    private var removeThisImageButton: XCUIElement  {
        return buttons(identifier: .removeThisImageButton)
    }
    
    private var doneCreatingPlants: XCUIElement {
        return buttons(identifier: .doneCreatingPlantButton)
    }
    
    private var cancelPlantButton: XCUIElement {
        return buttons(identifier: .cancelPlantButton)
    }
    
    private var testUserName = "Test Name"
    private var testUserPhoneNumber = "1234567890"
    private var testUserPW = "password"
    private var detailTextEntry = "Test detail entry for UI Testing."
    private var titleTextEntry = "Test title entry for UI Testing."
    
    func signInHelper() {
        let signInButton = app.segmentedControls.buttons["Sign In"]
        XCTAssert(signInButton.isHittable)
        signInButton.tap()

        phoneNumberTextField.tap()
        XCTAssert(phoneNumberTextField.isHittable)
        phoneNumberTextField.typeText(testUserPhoneNumber)
        XCTAssertTrue(phoneNumberTextField.value as? String == testUserPhoneNumber)

        passwordTextField.tap()
        passwordTextField.typeText(testUserPW)
        XCTAssertTrue(passwordTextField.value as? String == testUserPW)

        let point = CGPoint(x: 100, y: 100)
        app.tapCoordinate(at: point)

        let startButton = app.buttons.element(boundBy: 2)
        XCTAssertTrue(startButton.isHittable)
        startButton.tap()
    }
    
    func testUserSignIn() throws {
           let signInButton = app.segmentedControls.buttons["Sign In"]
           XCTAssert(signInButton.isHittable)
           signInButton.tap()

           userNameTextField.tap()
           XCTAssert(userNameTextField.isHittable)
           userNameTextField.typeText(testUserName)
           XCTAssertTrue(userNameTextField.value as? String == testUserName)

           passwordTextField.tap()
           passwordTextField.typeText(testUserPW)
           XCTAssertTrue(passwordTextField.value as? String == testUserPW)

           let point = CGPoint(x: 100, y: 100)
           app.tapCoordinate(at: point)

           let startButton = app.buttons.element(boundBy: 2)
           XCTAssertTrue(startButton.isHittable)
           startButton.tap()
       }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
//    func testCreatePlant() {
//        signInHelper()
//        XCTAssert(addToDoButton.isHittable)
//        addToDoButton.tap()
//
//        XCTAssert(addTitleTextField.isHittable)
//        addTitleTextField.tap()
//        addTitleTextField.typeText(titleTextEntry)
//        XCTAssertTrue(addTitleTextField.value as? String == titleTextEntry)
//
//        XCTAssert(addDetailTextView.isHittable)
//        addDetailTextView.tap()
//        addDetailTextView.typeText(detailTextEntry)
//        XCTAssertTrue(addDetailTextView.value as? String == detailTextEntry)
//
//        let point = CGPoint(x: 100, y: 30)
//        app.tapCoordinate(at: point)
//
//        XCTAssert(saveToDoButton.isHittable)
//        saveToDoButton.tap()
//    }

}

extension XCUIApplication {
    func tapCoordinate(at point: CGPoint) {
        let normalized = coordinate(withNormalizedOffset: .zero)
        let offset = CGVector(dx: point.x, dy: point.y)
        let coordinate = normalized.withOffset(offset)
        coordinate.tap()
    }
}
