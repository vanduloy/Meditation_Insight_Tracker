//
//  XHSScriptUITestsLaunchTests.swift
//  XHSScriptUITests
//
//  Created by Richard C. on 7/27/24.
//

import XCTest

class XHSScriptUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // 可以在这里添加启动后的检查逻辑，或者注释掉这一行
        // 测试启动应用程序是否成功
        XCTAssert(app.state == .runningForeground)
    }
}
