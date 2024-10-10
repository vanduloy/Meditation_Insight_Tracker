import SwiftUI

struct MeditationSelectionView: View {
    let userId: String
    var onCompletion: (Int) -> Void // 闭包用于返回选择的时长
    @State private var selectedDuration: Int?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    titleSection
                    durationButtonsSection
                    Spacer()
                }
                .padding(.horizontal)
                .frame(width: geometry.size.width)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    private var titleSection: some View {
        Text("Select Meditation Duration")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(.blue)
            .multilineTextAlignment(.center)
            .padding(.top, 50)
    }
    
    private var durationButtonsSection: some View {
        VStack(spacing: 20) {
            durationButton(duration: 10, gradient: [Color.blue, Color.blue.opacity(0.7)])
            durationButton(duration: 20, gradient: [Color.purple, Color.purple.opacity(0.7)])
        }
    }
    
    private func durationButton(duration: Int, gradient: [Color]) -> some View {
        Button(action: {
            selectedDuration = duration
            onCompletion(duration) // 选择时长后调用 onCompletion
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "clock.fill")
                Text("\(duration)-min Meditation")
            }
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: gradient),
                               startPoint: .leading,
                               endPoint: .trailing)
            )
            .cornerRadius(15)
            .shadow(color: gradient[0].opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
                .imageScale(.large)
        }
    }
}
