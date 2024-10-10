import XCTest

class XHSScriptUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        
        // 初始化应用程序
        app = XCUIApplication()
        
        // 启动应用程序
        app.launch()
        
        // 确保在测试结束后进行清理
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
        
        // 关闭应用程序
        app.terminate()
    }

    func testAutoBuy() {
        // 获取按钮
        let buyButton = app.buttons["去购买"]
        
        // 循环等待按钮变为可点击状态
        while !buyButton.exists || !buyButton.isHittable {
            sleep(UInt32(0.1)) // 设置适当的检查间隔时间
        }
        
        // 按钮变为可点击状态后，立即点击
        buyButton.tap()
    }
}



