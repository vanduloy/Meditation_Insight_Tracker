import SwiftUI

struct MeditationResultsPopup: View {
    @State private var navigateToSurvey = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("🎉 Congratulations! 🎉")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)

                Text("You've Made It!")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.center)

                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)

                Text("Your historical ECG and HRV data results can be seen in the dashboard.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                Button(action: {
                    navigateToSurvey = true
                }) {
                    Text("Final Short Questionnaire")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .fullScreenCover(isPresented: $navigateToSurvey) {
                    MeditationSurveyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
        }
    }
}

struct MeditationResultsPopup_Previews: PreviewProvider {
    static var previews: some View {
        MeditationResultsPopup()
    }
}
