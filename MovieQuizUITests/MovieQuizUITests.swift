//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Nastya Adodina on 10.06.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
  
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
        
        func testGameFinish() {
            sleep(3)
            for _ in 1...10 {
                app.buttons["No"].tap()
                sleep(2)
            }
            
            let alert = app.alerts["Game results"]
            
            XCTAssertTrue(alert.exists)
            XCTAssertTrue(alert.label == "Этот раунд окончн!")
            XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
        }
        func testAlertDismiss() {
            sleep(2)
            for _ in 1...10 {
                app.buttons["No"].tap()
                sleep(2)
            }
            let alert = app.alerts["Game results"]
            alert.buttons.firstMatch.tap()
            
            sleep(2)
            
            let indexLabel = app.staticTexts["Index"]
            
            XCTAssertFalse(alert.exists)
            XCTAssertTrue(indexLabel.label == "1/10")
        }
    }
}
