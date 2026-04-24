//
//  TrackMateUITests.swift
//  TrackMateUITests
//
//  Created by Glen Mars on 4/8/25.
//

import XCTest

final class TrackMateUITests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		
		// In UI tests it is usually best to stop immediately when a failure occurs.
		continueAfterFailure = false
		
		// In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
	}
	
	// MARK: - Navigation Tabs
	
	func testMainNavigationTabs() throws {
		// Launch
		let app = XCUIApplication()
		
		// Force AppLock to be false during testing so testing bot doesn't get stuck.
		app.launchArguments = ["-requireAppLock", "false"]
		app.launch()
		
		/// Interactions Tab
		let interactionsTab = app.tabBars.buttons["Interactions"]
		XCTAssertTrue(interactionsTab.exists, "The Interactions tab button is missing.")
		interactionsTab.tap()
		
		/// Journal Tab
		let journalTab = app.tabBars.buttons["Journal"]
		XCTAssertTrue(journalTab.exists, "The Journal tab button is missing.")
		journalTab.tap()
		
		/// Red Flag Tab
		let redFlagsTab = app.tabBars.buttons["Red Flags"]
		XCTAssertTrue(redFlagsTab.exists, "The Red Flags tab button is missing.")
		redFlagsTab.tap()
		
		/// Analysis Tab
		let analysisTab = app.tabBars.buttons["Analysis"]
		XCTAssertTrue(analysisTab.exists, "The Analysis tab button is missing.")
		analysisTab.tap()
		
		/// Settings Tab
		let settingsTab = app.tabBars.buttons["Settings"]
		XCTAssertTrue(settingsTab.exists, "The Settings tab button is missing.")
		settingsTab.tap()
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
}
