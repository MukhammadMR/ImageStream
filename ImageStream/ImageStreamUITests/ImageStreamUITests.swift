import XCTest
@testable import ImageStream

final class ImageStreamUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
    }
    
    func testAuth() throws {
        app.launchArguments.append("UITest_reset")
        app.launch()
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testProfile() throws {
        
        app.launch()
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts.element(boundBy: 0).exists)
        XCTAssertTrue(app.staticTexts.element(boundBy: 1).exists)
        
        app.buttons["logout button"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Выйти"].tap()
    }
    
    func testFeed() throws {
        app.launch()
        
        let table = app.tables.element
        XCTAssertTrue(table.waitForExistence(timeout: 5), "❌ Feed table did not appear")
        
        table.swipeUp()
        
        let firstCell = table.cells.element(boundBy: 1)
        let likeButton = firstCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "❌ Like button not found")
        
        likeButton.tap()
        
        firstCell.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        let shareButton = app.buttons["share button"]
        XCTAssertTrue(shareButton.waitForExistence(timeout: 5), "❌ Share button not found — fullscreen likely didn't open")
        
        image.pinch(withScale: 2.0, velocity: 1.0)
        image.pinch(withScale: 0.5, velocity: -1.0)
        
        app.buttons["nav back button white"].tap()
    }
}
