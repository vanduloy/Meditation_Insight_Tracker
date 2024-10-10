import SwiftUI

struct MainView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @State private var selectedTab: Tab = .home
    @State private var userId: String = UserDefaults.standard.string(forKey: "userId") ?? ""
    
    enum Tab {
        case home
        case dashboard
        case tutorial
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                tabContent
                
                VStack {
                    Spacer()
                    customTabBar
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            DispatchQueue.global(qos: .background).async {
                setupUser()
            }
        }
    }
    
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .home:
                LazyView {
                    ContentView(userId: userId)
                }
            case .dashboard:
                LazyView {
                    DashboardView(userId: userId)
                }
            case .tutorial:
                TutorialView()
            }
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(tab: .home, imageName: "house.fill", title: "Home")
            tabButton(tab: .dashboard, imageName: "chart.bar.fill", title: "Dashboard")
            tabButton(tab: .tutorial, imageName: "book.fill", title: "Tutorial")
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal)
    }
    
    private func tabButton(tab: Tab, imageName: String, title: String) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(systemName: imageName)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(selectedTab == tab ? .blue : .gray)
            .frame(maxWidth: .infinity)
        }
    }

    // 将用户生成放入后台线程
    private func setupUser() {
        if userId.isEmpty {
            DispatchQueue.main.async {
                let randomNumber = Int.random(in: 1...50)
                userId = "User\(randomNumber)"
                UserDefaults.standard.set(userId, forKey: "userId")
            }
        }
    }
}

// 通过 LazyView 实现懒加载
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}


//import SwiftUI
//
//struct MainView: View {
//    @EnvironmentObject private var healthKitManager: HealthKitManager
//    @State private var selectedTab: Tab = .home
//    @State private var userId: String = UserDefaults.standard.string(forKey: "userId") ?? ""
//    
//    enum Tab {
//        case home
//        case dashboard
//        case tutorial
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // 简化背景设计
//                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
//                               startPoint: .topLeading,
//                               endPoint: .bottomTrailing)
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack(spacing: 0) {
//                    switch selectedTab {
//                    case .home:
//                        ContentView(userId: userId)
//                    case .dashboard:
//                        DashboardView(userId: userId)
//                    case .tutorial:
//                        TutorialView()
//                    }
//                    
//                    customTabBar
//                }
//            }
//            .edgesIgnoringSafeArea(.bottom)
//            .onAppear {
//                DispatchQueue.global(qos: .userInitiated).async {
//                    setupUser()
//                }
//            }
//        }
//    }
//    
//    private var customTabBar: some View {
//        HStack(spacing: 0) {
//            tabButton(tab: .home, imageName: "house.fill", title: "Home")
//            tabButton(tab: .dashboard, imageName: "chart.bar.fill", title: "Dashboard")
//            tabButton(tab: .tutorial, imageName: "book.fill", title: "Tutorial")
//        }
//        .padding(.vertical, 10)
//        .background(
//            RoundedRectangle(cornerRadius: 25)
//                .fill(Color.white)
//                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: -5)
//        )
//        .padding(.horizontal)
//        .padding(.bottom, 5)
//    }
//    
//    private func tabButton(tab: Tab, imageName: String, title: String) -> some View {
//        Button(action: {
//            selectedTab = tab
//            print("Tab切换到了: \(tab)") // 添加print来调试
//        }) {
//            VStack(spacing: 4) {
//                Image(systemName: imageName)
//                    .font(.system(size: 24))
//                Text(title)
//                    .font(.caption)
//            }
//            .foregroundColor(selectedTab == tab ? .blue : .gray)
//            .frame(maxWidth: .infinity)
//        }
//    }
//
//    
//    private func setupUser() {
//        if userId.isEmpty {
//            let randomNumber = Int.random(in: 1...50)
//            userId = "User\(randomNumber)"
//            UserDefaults.standard.set(userId, forKey: "userId")
//        }
//    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//            .environmentObject(HealthKitManager())
//    }
//}
//
