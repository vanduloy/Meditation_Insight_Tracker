import SwiftUI

struct SurveyView: View {
    var isBefore: Bool
    var userId: String
    var onCompletion: () -> Void
    @State private var stressLevel: Int = 5
    @State private var sleepQuality: Int = 3
    @State private var focusLevel: Int = 3
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: geometry.size.height * 0.03) {
                    titleSection
                    
                    if isBefore {
                        stressLevelSelector(geometry: geometry)
                        sleepQualityPicker(geometry: geometry)
                    } else {
                        focusLevelSelector(geometry: geometry)
                        stressLevelSelector(geometry: geometry)
                    }
                    
                    submitButton(geometry: geometry)
                }
                .padding(.horizontal, geometry.size.width * 0.02)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            )
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            disableSwipeBackGesture()
        }
    }
    
    private func submitButton(geometry: GeometryProxy) -> some View {
        Button(action: {
            submitSurvey()
        }) {
            Text("Submit")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(25)
        }
        .padding(.top, geometry.size.height * 0.02)
    }
    
    private func submitSurvey() {
        let surveyData: [String: Any] = [
            "userId": userId,
            "timestamp": Date(),
            "isBefore": isBefore,
            "stressLevel": stressLevel,
            "sleepQuality": isBefore ? sleepQuality : nil,
            "focusLevel": isBefore ? nil : focusLevel
        ]
        
        // 打印用户输入的数据
        print("Survey submitted:", surveyData)
        
        // 调用回调，返回到UserJourneyView，并标记为完成
        onCompletion()
        
        // 返回上一个视图（UserJourneyView）
        presentationMode.wrappedValue.dismiss()
    }
    
    private func disableSwipeBackGesture() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }
        
        if let navigationController = rootVC as? UINavigationController {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    private var titleSection: some View {
        HStack {
            Text("2")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.blue))
            
            Text(isBefore ? "Pre-Meditation Survey" : "Post-Meditation Survey")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(.top, 20)
    }
    
    private func stressLevelSelector(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How would you rate your current stress level?")
                .font(.headline)
                .foregroundColor(.black)
            
            let buttonSize = min(geometry.size.width * 0.07, 30)
            
            HStack {
                ForEach(1...10, id: \.self) { level in
                    Button(action: {
                        stressLevel = level
                    }) {
                        Text("\(level)")
                            .font(.system(size: buttonSize * 0.5))
                            .foregroundColor(stressLevel == level ? .white : .blue)
                            .frame(width: buttonSize, height: buttonSize)
                            .background(
                                Circle()
                                    .fill(stressLevel == level ? Color.blue : Color.white)
                                    .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)
                            )
                    }
                }
            }
            
            HStack {
                Text("Not at all stressed")
                    .font(.caption)
                Spacer()
                Text("Extremely stressed")
                    .font(.caption)
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
    }
    
    private func sleepQualityPicker(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How well did you sleep last night?")
                .font(.headline)
                .foregroundColor(.black)
            
            let buttonWidth = min(geometry.size.width * 0.15, 60)
            let buttonHeight = buttonWidth
            
            HStack {
                ForEach(1...5, id: \.self) { quality in
                    Button(action: {
                        sleepQuality = quality
                    }) {
                        VStack {
                            Text(sleepQualityText(for: quality))
                                .font(.system(size: buttonWidth * 0.2))
                                .foregroundColor(sleepQuality == quality ? .white : .blue)
                                .multilineTextAlignment(.center)
                            
                            Text("\(quality)")
                                .font(.system(size: buttonWidth * 0.3, weight: .medium))
                                .foregroundColor(sleepQuality == quality ? .white : .blue)
                        }
                        .frame(width: buttonWidth, height: buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(sleepQuality == quality ? Color.blue : Color.white)
                                .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)
                        )
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
    }
    
    private func sleepQualityText(for quality: Int) -> String {
        switch quality {
        case 1: return "Very poorly"
        case 2: return "Poorly"
        case 3: return "Okay"
        case 4: return "Well"
        case 5: return "Very well"
        default: return ""
        }
    }
    
    private func focusLevelSelector(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How well could you focus on today's meditation session?")
                .font(.headline)
                .foregroundColor(.black)
            
            let buttonSize = min(geometry.size.width * 0.09, 30)
            
            HStack {
                ForEach(0...5, id: \.self) { level in
                    Button(action: {
                        focusLevel = level
                    }) {
                        Text("\(level)")
                            .font(.system(size: buttonSize * 0.5))
                            .foregroundColor(focusLevel == level ? .white : .blue)
                            .frame(width: buttonSize, height: buttonSize)
                            .background(
                                Circle()
                                    .fill(focusLevel == level ? Color.blue : Color.white)
                                    .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)
                            )
                    }
                }
            }
            
            HStack {
                Text("Not at all focused")
                    .font(.caption)
                Spacer()
                Text("Completely focused")
                    .font(.caption)
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
    }
    
//    private func submitButton(geometry: GeometryProxy) -> some View {
//        Button(action: {
//            submitSurvey()
//        }) {
//            Text("Submit")
//                .font(.headline)
//                .foregroundColor(.white)
//                .frame(height: 50)
//                .frame(maxWidth: .infinity)
//                .background(Color.blue)
//                .cornerRadius(25)
//        }
//        .padding(.top, geometry.size.height * 0.02)
//    }
//    
//    private func submitSurvey() {
//        let surveyData: [String: Any] = [
//            "userId": userId,
//            "timestamp": Date(),
//            "isBefore": isBefore,
//            "stressLevel": stressLevel,
//            "sleepQuality": isBefore ? sleepQuality : nil,
//            "focusLevel": isBefore ? nil : focusLevel
//        ]
//        
//        // Log the collected data
//        print("Survey submitted:", surveyData)
//        
//        // Call the completion handler
//        onCompletion()
//    }
}

