import SwiftUI

struct ContentView: View {
    var userId: String
    @State private var navigateToUserJourney = false
    @State private var isContentLoaded = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundDesign
                
                if isContentLoaded {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 100)
                        
                        welcomeSection
                        
                        Spacer().frame(height: 40)
                        
                        Image("MainPage")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .cornerRadius(15)
                        
                        Spacer().frame(height: 40)
                        
                        buttonSection()
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                } else {
                    ProgressView("Loading...")
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationDestination(isPresented: $navigateToUserJourney) {
                UserJourneyView(userId: userId)
            }
        }
        .onAppear {
            loadContent()
        }
    }
    
    private var backgroundDesign: some View {
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    private var welcomeSection: some View {
        Text("Welcome, \(userId)")
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func buttonSection() -> some View {
        Button(action: { navigateToUserJourney = true }) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                Text("Start Meditation")
                    .font(.system(size: 20, weight: .semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                               startPoint: .leading,
                               endPoint: .trailing)
            )
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
    
    private func loadContent() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
            DispatchQueue.main.async {
                isContentLoaded = true
            }
        }
    }
}
