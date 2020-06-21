//
//  ScreenshotHelper.swift
//  ScreenshotHelper
//
//  Created by Paul on 20.06.20.
//  Copyright © 2020 Polip. All rights reserved.
//

import XCTest

class ScreenshotHelper: XCTestCase {
    
    override func setUp() {
        print("Setup…")
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: ["-savedLevel", "5"])
        app.launchArguments.append(contentsOf: ["-enableDebug", "true"])
        app.launchArguments.append(contentsOf: ["-useSwipeGestures", "true"])
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTakeScreenshots() {
        XCUIDevice.shared.orientation = .landscapeRight
        print("Taking screenshots...")
        
        // UI tests must launch the application that they test.
        
        let app = XCUIApplication()
        setupSnapshot(app)
        XCUIDevice.shared.orientation = .landscapeRight // option must be ticked in Simulator
        sleep(1)
        
        app.buttons["Play"].tap()
        app.buttons["Resume"].tap()
        
        
        sleep(1)
        print("Level 5")
        /* Level 5 */
        snapshot("Level-5-scientific")
        
        let menuElement = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element

        /* Go to Level 6 */
        menuElement.tap(withNumberOfTaps: 5, numberOfTouches: 1)
        sleep(1)
        menuElement.tap(withNumberOfTaps: 5, numberOfTouches: 1)
        print("Level 6")
        sleep(2)
        snapshot("Level-6-platform")
        
        /* Go to Level 7 */
        menuElement.tap(withNumberOfTaps: 5, numberOfTouches: 1)
        sleep(3)
        print("Level 7")
        // Move right
        
        menuElement.swipeRight()
        sleep(1)
        // if tap to move
        // menuElement.coordinate(withNormalizedOffset: CGVector.zero).withOffset(CGVector(dx:300,dy:-60))/*@START_MENU_TOKEN@*/.press(forDuration: 1.3);/*[[".tap()",".press(forDuration: 1.3);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        snapshot("Level-7-crate")
        
        menuElement.tap(withNumberOfTaps: 5, numberOfTouches: 1)
        sleep(3)
        print("Level 8")
        snapshot("Level-8-stairs")
    }
    
    /*
    func testScreenshotLevel7() {
        XCUIDevice.shared.orientation = .landscapeRight

        print("Taking screenshots for level 7...")
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: ["-savedLevel", "7"])

        setupSnapshot(app)

        app.buttons["Play"].tap()
        app.buttons["Resume"].tap()

        sleep(1)

        snapshot("Level-7-platform")
    }
    */
    
    func testLaunchPerformance() {
        /*print("Launch performance…")
        print("...")
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }*/
    }
}
