import SwiftUI

struct UserJourneyView: View {
    var userId: String
    @State private var completedSteps: Set<Int> = []
    @State private var selectedDuration: Int? = nil // 存储用户选择的时长
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToSurvey = false
    @State private var navigateToECG = false
    @State private var navigateToMeditationSelection = false // 新增状态用于导航到 MeditationSelection
    @State private var navigateToMeditation = false
    @State private var isPreMeditationSurvey = true
    @State private var isPreMeditationECG = true

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: geometry.size.height * 0.02) {
                    Text("Study Routine")
                        .font(.system(size: min(geometry.size.width * 0.06, 28), weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(.top, geometry.size.height * 0.02)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Text("Click each step to proceed. Once completed, it will be checked, and you can move to the next step.")
                        .font(.system(size: min(geometry.size.width * 0.04, 16), weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    detailedSteps(geometry: geometry)
                }
                .padding(.horizontal, geometry.size.width * 0.05)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            )
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToSurvey) {
            SurveyView(isBefore: isPreMeditationSurvey, userId: userId, onCompletion: {
                completedSteps.insert(isPreMeditationSurvey ? 1 : 6)
                navigateToSurvey = false
            })
        }
        .navigationDestination(isPresented: $navigateToECG) {
            ECGMeasurementView(isPreMeditation: .constant(isPreMeditationECG), userId: userId, onCompletion: {
                completedSteps.insert(isPreMeditationECG ? 2 : 5)
                navigateToECG = false
            })
        }
        .navigationDestination(isPresented: $navigateToMeditationSelection) {
            MeditationSelectionView(userId: userId, onCompletion: { duration in
                self.selectedDuration = duration // 获取用户选择的时长
                completedSteps.insert(3) // 标记步骤 3 已完成
                navigateToMeditationSelection = false
            })
        }
        .navigationDestination(isPresented: $navigateToMeditation) {
            if let duration = selectedDuration {
                MeditationPlayView(duration: duration, userId: userId, onCompletion: {
                    completedSteps.insert(4) // 标记 MeditationPlayView 完成
                    navigateToMeditation = false
                })
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Reminder"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func detailedSteps(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            ForEach(Array(zip(steps.indices, steps)), id: \.0) { index, step in
                stepCard(index: index, step: step, instruction: detailedInstructions[index], geometry: geometry)
            }
        }
    }
    
    private func stepCard(index: Int, step: String, instruction: String, geometry: GeometryProxy) -> some View {
        let cardWidth = geometry.size.width * 0.9
        let cardHeight = geometry.size.height * 0.15
        let fontSize = min(geometry.size.width * 0.04, 16)
        let circleSize = cardHeight * 0.25
        let isClickable = canProceed(to: index)
        
        return Button(action: {
            handleStepClick(index)
        }) {
            ZStack {
                HStack(alignment: .center) {
                    VStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(completedSteps.contains(index) ? Color.green : Color.blue)
                                .frame(width: circleSize, height: circleSize)
                            
                            if completedSteps.contains(index) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: fontSize))
                            } else {
                                Text("\(index + 1)")
                                    .foregroundColor(.white)
                                    .font(.system(size: fontSize, weight: .bold))
                            }
                        }
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: cardHeight * 0.03) {
                        Text(step)
                            .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(instruction)
                            .font(.system(size: fontSize * 0.8, design: .rounded))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .opacity(isClickable ? 1 : 0.3)
                }
                .padding(cardWidth * 0.03)
                .frame(width: cardWidth, height: cardHeight)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                )
                
                if !isClickable {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: cardWidth, height: cardHeight)
                }
            }
        }
        .disabled(!isClickable)
    }

    private func handleStepClick(_ index: Int) {
        switch index {
        case 0:
            completedSteps.insert(0)
        case 1:
            isPreMeditationSurvey = true
            navigateToSurvey = true
        case 2:
            isPreMeditationECG = true
            navigateToECG = true
        case 3:
            navigateToMeditationSelection = true // 新增步骤：进入Meditation Selection
        case 4:
            navigateToMeditation = true // 使用选择的时长导航到 MeditationPlayView
        case 5:
            isPreMeditationSurvey = false
            navigateToSurvey = true
        default:
            break
        }
    }
    
    private func canProceed(to index: Int) -> Bool {
        if index == 0 {
            return true
        }
        return completedSteps.contains(index - 1) || completedSteps.contains(index)
    }
    
    private let steps = [
        "Get Prepared",
        "Pre-Meditation Survey",
        "Pre-meditation ECG Measurement",
        "Meditation Duration Selection", // 新增步骤
        "Meditate",
        "Post-meditation ECG Measurement",
        "Post-Meditation Survey"
    ]
    
    private let detailedInstructions = [
        "Find a comfortable, quiet place where you won't be disturbed for the duration of the session.",
        "You'll be presented with two questions about your current state of mind. Answer them honestly.",
        "Follow the instructions on your Apple Watch to take two 1-minute ECG readings before starting meditation.",
        "Select either a 10 or 20-minute meditation session.", // 新增说明
        "Follow the guided meditation based on your selected duration.",
        "After the meditation, take two more 1-minute ECG readings on your Apple Watch.",
        "Finally, answer two more questions about your post-meditation state of mind."
    ]
}
