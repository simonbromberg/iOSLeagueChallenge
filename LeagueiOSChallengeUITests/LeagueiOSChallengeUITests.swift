//
//  LeagueiOSChallengeUITests.swift
//  LeagueiOSChallengeUITests
//
//  Copyright © 2024 League Inc. All rights reserved.
//

import XCTest

class LeagueiOSChallengeUITests: XCTestCase {
  let app = XCUIApplication()

  func testLoginFlow() {
    app.launch()

    let navigation = app.navigationBars["Posts"]
    let logoutButton = navigation.buttons["Logout"]
    let exitButton = navigation.buttons["Exit"]

    if logoutButton.exists {
      logoutButton.tap()
    } else if exitButton.exists {
      exitButton.tap()
      app.alerts.buttons["OK"].tap()
    }

    let usernameField = app.textFields["Username"]
    _ = usernameField.waitForExistence(timeout: 5)
    usernameField.tap()
    usernameField.typeText("foo")

    let passwordField = app.secureTextFields["Password"]
    passwordField.tap()
    passwordField.typeText("bar")

    let loginButton = app.buttons["Login"]
    loginButton.tap()

    _ = navigation.waitForExistence(timeout: 5)

    app.staticTexts["postUsernameLabel"].firstMatch.tap()
    app.buttons["closeButton"].tap()

    logoutButton.tap()

    XCTAssertEqual(usernameField.value as? String, usernameField.placeholderValue)
  }
}
