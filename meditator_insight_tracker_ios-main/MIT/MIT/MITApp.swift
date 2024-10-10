import SwiftUI

@main
struct MITApp: App {
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(healthKitManager)
                .onAppear {
                    // 使用回调函数进行 HealthKit 授权和数据获取
                    healthKitManager.requestAuthorization { success, error in
                        if success {
                            healthKitManager.fetchPPGHRVData { success, error in
                                if success {
                                    print("PPG HRV 数据获取成功")
                                } else {
                                    print("PPG HRV 数据获取失败: \(String(describing: error?.localizedDescription))")
                                }
                            }
                        } else {
                            print("授权失败: \(String(describing: error?.localizedDescription))")
                        }
                    }
                }
        }
    }
}
