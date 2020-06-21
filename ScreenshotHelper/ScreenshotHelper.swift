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
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
//        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeRight;
        let device = XCUIDevice.shared
        device.orientation = .landscapeRight
        
        print("Setup…")
        
        
        let app = XCUIApplication()
        
        app.launchArguments.append(contentsOf: ["-savedLevel", "6"])
        
        //setupSnapshot(app)
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // 2016 code
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        // XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTakeScreenshots() {
        let device = XCUIDevice.shared
        device.orientation = .landscapeRight
        //XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeRight;
        XCUIDevice.shared.orientation = .landscapeRight
        
        print("Taking screenshots...")
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        
        app.buttons["Play"].tap()
//        app.buttons["New Game"].tap()
        //app.buttons["Resume"].tap()
        app.buttons["Resume"].tap()
//        app.buttons["New Game"].tap()

        snapshot("level")
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        /*
         app.buttons["Play"].tap()
         app.buttons["New Game"].tap()
         
         let menuElement = app.otherElements.containingType(.Button, identifier:"Menu").element
         
         menuElement.tapWithNumberOfTaps(7, numberOfTouches: 1)
         
         menuElement.tapWithNumberOfTaps(5, numberOfTouches: 1)
         
         snapshot("game01")
         */
        
        
        
        
        
    }
    
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
