//
//  Edgar_Explorer_UITests4.swift
//  Edgar_Explorer_UITests4
//
//  Created by Paul on 03.06.16.
//  Copyright © 2016 Polip. All rights reserved.
//

import XCTest

class Edgar_Explorer_UITests4: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        print("Test log")
        
        let app = XCUIApplication()
        setupSnapshot(app: app)
        app.launch()
        
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        /*
        let app = XCUIApplication()

        //snapshot("testscreencapture")
        
        
        app.buttons["Play"].tap()
        app.buttons["New Game"].tap()
        
        let menuElement = app.otherElements.containingType(.Button, identifier:"Menu").element

        menuElement.tapWithNumberOfTaps(7, numberOfTouches: 1)
        
        menuElement.tapWithNumberOfTaps(5, numberOfTouches: 1)
        
        snapshot("game01")
        */
        
        
        let app = XCUIApplication()
        app.buttons["Play"].tap()
//        app.buttons["Resume"].tap()
        app.buttons["New Game"].tap()
        
        let menuElement = app.otherElements.containing(.button, identifier:"Menu").element
/*
        menuElement.tapWithNumberOfTaps(7, numberOfTouches: 1)
        sleep(1)
        menuElement.tapWithNumberOfTaps(5, numberOfTouches: 1) // go to level 2
        sleep(1)
        menuElement.tapWithNumberOfTaps(5, numberOfTouches: 1) // go to level 3
        sleep(1)
        menuElement.tapWithNumberOfTaps(5, numberOfTouches: 1) // go to level 4
*/
        app.buttons["†"].tap()
        sleep(1)
        
        menuElement.tap()
        
        menuElement.swipeLeft();
        menuElement.swipeRight();
        menuElement.swipeUp()
        menuElement.tap()
        
        snapshot(name: "train")
        
        sleep(1)
        
        menuElement.tap()
        
        sleep(7)
        
        menuElement.swipeLeft();
        menuElement.swipeLeft();
        
        sleep(1)
        
        menuElement.tap()
        
        sleep(3)
        
        menuElement.swipeLeft()
        
        menuElement.swipeUp()
        snapshot(name: "game02")
        
        menuElement.swipeUp()
        menuElement.swipeUp()
        
        snapshot(name: "game03")
        
        menuElement.swipeUp()
        snapshot(name: "game04")
        
        menuElement.swipeUp()
        
    }
    
}
