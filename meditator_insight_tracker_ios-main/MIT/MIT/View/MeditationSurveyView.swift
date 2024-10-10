import SwiftUI

struct MeditationSurveyView: View {
    @State private var selectedFeeling: Int = 3
    @State private var selectedDepth: Int = 5
    @State private var selectedEfficacy: Int = 5
    @State private var navigateToMainView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        titleSection
                        
                        VStack(spacing: 20) {
                            questionSection(
                                title: "How are you feeling?",
                                range: 1...5,
                                selected: $selectedFeeling,
                                content: feelingContent
                            )
                            
                            questionSection(
                                title: "Perceived Depth of Meditation",
                                range: 1...10,
                                selected: $selectedDepth,
                                content: { depthContent($0, totalItems: 10) }
                            )
                            
                            questionSection(
                                title: "Perceived Efficacy of the Session",
                                range: 1...10,
                                selected: $selectedEfficacy,
                                content: { efficacyContent($0, totalItems: 10) }
                            )
                        }
                        .frame(width: geometry.size.width - 40)
                        
                        submitButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                    .frame(minHeight: geometry.size.height)
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                )
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToMainView) {
                MainView()
                    .navigationBarBackButtonHidden(true) // Ensures the back button does not appear in MainView
            }
        }
    }
    
    private var titleSection: some View {
        Text("Post Meditation Survey")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func questionSection<Content: View>(title: String, range: ClosedRange<Int>, selected: Binding<Int>, content: @escaping (Int) -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
            
            HStack {
                ForEach(range, id: \.self) { index in
                    VStack {
                        content(index)
                            .onTapGesture {
                                selected.wrappedValue = index
                            }
                        Text("\(index)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private func feelingContent(_ index: Int) -> some View {
        Image(systemName: selectedFeeling >= index ? "face.smiling.fill" : "face.smiling")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundColor(selectedFeeling >= index ? .yellow : .gray)
    }
    
    private func depthContent(_ index: Int, totalItems: Int) -> some View {
        Circle()
            .frame(width: CGFloat(30 - totalItems + 5), height: CGFloat(30 - totalItems + 5))
            .foregroundColor(selectedDepth >= index ? .blue : .gray)
    }
    
    private func efficacyContent(_ index: Int, totalItems: Int) -> some View {
        Circle()
            .frame(width: CGFloat(30 - totalItems + 5), height: CGFloat(30 - totalItems + 5))
            .foregroundColor(selectedEfficacy >= index ? .blue : .gray)
    }
    
    private var submitButton: some View {
        Button(action: {
            navigateToMainView = true
        }) {
            Text("Submit")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .cornerRadius(15)
        }
        .padding(.vertical, 20)
        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

struct MeditationSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MeditationSurveyView()
        }
    }
}
