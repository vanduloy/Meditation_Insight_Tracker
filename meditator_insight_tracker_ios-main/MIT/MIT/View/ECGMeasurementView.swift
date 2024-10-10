import SwiftUI

struct ECGDataPoint: Codable {
    let timestamp: Double
    let voltage: Double
}

struct ECGMeasurementData: Codable {
    let userId: String
    let stage: String
    let ecgVoltage: [ECGDataPoint]
    let time: Date
}

struct ECGMeasurementView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @Binding var isPreMeditation: Bool
    let userId: String
    @State private var measurementStatus = ""
    @State private var isLoading = false
    @State private var showResults = false
    @State private var latestHRV: Double?
    @State private var navigateToNextView = false
    @State private var showResultsPopup = false
    @State private var measurementStartTime: Date?
    @State private var voltageReadingsCount: Int = 0
    @State private var measurementTimer: Timer?
    @State private var measurementCount = 1
    @State private var ecgMeasurementData: ECGMeasurementData?
    @State private var showNotification = false
    
    var onCompletion: () -> Void
    
    let apiUrl = "http://ECGMeasurement-env.eba-v9idakyc.us-east-2.elasticbeanstalk.com/api/ecg-data"
    let chunkSize = 500  // Define chunk size (can be adjusted)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {  // 使用 ScrollView 来让页面滚动
                    VStack(spacing: 30) {
                        titleSection
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                        
                        instructionsSection

                        nextButton
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(width: geometry.size.width)
                }
                
                // 错误提示弹出框
                if showNotification {
                    VStack {
                        Text("Failed to retrieve data. Please try again.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)  // 统一背景
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.opacity)
                            .animation(.easeInOut, value: showNotification)  // 使用 animation(_:value:) 替换
                    }
                    .frame(width: geometry.size.width * 0.8)  // 修改宽度，去掉多余的背景和frame
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.9)  // 修改位置到屏幕下方
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }


    
    private var titleSection: some View {
        HStack {
            if measurementCount == 1 {
                Image(systemName: "1.circle.fill") // Icon for Step 1
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                
                Text("Measure your ")
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .foregroundColor(.blue)
                    +
                Text("FIRST ")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    +
                Text("ECG on Apple Watch")
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "2.circle.fill") // Icon for Step 2
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                
                Text("Measure your ")
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .foregroundColor(.blue)
                    +
                Text("SECOND ")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    +
                Text("ECG on Apple Watch")
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .foregroundColor(.blue)
            }
        }
        .padding(.top, 50)
        .multilineTextAlignment(.center)
    }
    
    
    private var instructionsSection: some View {
        VStack(spacing: 10) {
            // 第一次测量完成后的文案
            if showResults && measurementCount == 1 {
                VStack(spacing: 10) {
                    Text("You measured your first ECG today! Please proceed for the second one.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, UIScreen.main.bounds.width * 0.02)
            }
            
            // 第二次测量完成后的文案
            else if showResults && measurementCount == 2 {
                VStack(spacing: 10) {
                    Text("Congratulations!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                    
                    Text("You measured all your Pre-meditation ECG.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, UIScreen.main.bounds.width * 0.02)
            }
            
            // 第一次测量前和测量中的文案
            else if measurementCount == 1 && !showResults {
                if !isLoading {
                    // 第一次测量前的提示
                    VStack(spacing: 5) {
                        Text("Recommended: Find yourself in a place connected with Wi-Fi")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.02)
                    
                    VStack(spacing: 5) {
                        Text("IMPORTANT: You will measure 30 seconds of ECG twice to complete 1 minute of ECG recording.")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.02)
                } else {
                    // 第一次测量中的提示
                    VStack(spacing: 10) {
                        Text("Instruction")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                        
                        Text("1. Open your ECG app on Apple Watch.\nThen, hold your finger on the crown on the right side.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.leading) // 多行文本左对齐
                            .frame(maxWidth: .infinity, alignment: .leading) // 确保整个文本框左对齐
                            .lineLimit(nil)
                        
                        Image("AppleWatch")  // 使用你在 Assets.xcassets 中的图片
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                        
                        Text("2. Once you record your ECG on Apple Watch, this mobile app will fetch the data automatically.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.leading) // 多行文本左对齐
                            .frame(maxWidth: .infinity, alignment: .leading) // 确保整个文本框左对齐
                            .lineLimit(nil)
                        
                        Text("3. The Next Step button will appear once the data is successfully recorded.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.leading) // 多行文本左对齐
                            .frame(maxWidth: .infinity, alignment: .leading) // 确保整个文本框左对齐
                            .lineLimit(nil)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.02)
                    
                    VStack(spacing: 5) {
                        Text("Warning: Apple Watch requires that you stand/sit still and hold your crown while measuring. If not, you may need to record it again.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading) // 多行文本左对齐
                            .frame(maxWidth: .infinity, alignment: .leading) // 确保整个文本框左对齐
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.02)
                }
            }
            
            // 第二次测量中的提示
            else if measurementCount == 2 && !showResults {
                VStack(spacing: 10) {
                    Text("Instruction")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                    
                    Text("1. Hold your finger again on the crown on the right side.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.leading) // 多行文本左对齐
                        .frame(maxWidth: .infinity, alignment: .leading) // 确保整个文本框左对齐
                        .lineLimit(nil)
                    
                    Text("2. Once you record your ECG on Apple Watch, this mobile app will fetch the data automatically.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.leading) // 多行文本左对齐
                        .frame(maxWidth: .infinity, alignment: .leading) // 确保整个文本框左对齐
                        .lineLimit(nil)
                    
                    Text("3. The Next Step button will appear once the data is successfully recorded.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.leading) // 多行文本左对齐
                        .frame(maxWidth: .infinity, alignment: .leading) // 确保整个文本框左对齐
                        .lineLimit(nil)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, UIScreen.main.bounds.width * 0.02)
                
                VStack(spacing: 5) {
                    Text("Warning: Apple Watch requires that you stand/sit still and hold your crown while measuring. If not, you may need to record it again.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading) // 多行文本左对齐
                        .frame(maxWidth: .infinity, alignment: .leading) // 确保整个文本框左对齐
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, UIScreen.main.bounds.width * 0.02)
            }
        }
        .padding()
    }
    
    private var nextButton: some View {
        Group {
            // Initial state: Display "Start the First Measurement" button before starting the first measurement
            if measurementCount == 1 && !isLoading && !showResults {
                Button(action: {
                    // Start the first ECG measurement
                    startECGMeasurement()
                }) {
                    Text("Start the First Measurement")
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
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.bottom, 30)
            }
            
            // First measurement completed: Display "Start the Second Measurement" button
            else if showResults && measurementCount == 1 {
                Button(action: {
                    measurementCount += 1
                    resetMeasurementState()
                    startECGMeasurement()  // Directly start the second measurement
                }) {
                    Text("Start the Second Measurement")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.7)]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.purple.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.bottom, 30)
            }
            
            // Second measurement completed: Display "Next" button to return to UserJourneyView and mark as complete
            else if showResults && measurementCount == 2 {
                Button(action: {
                    onCompletion()  // Call the completion handler or navigate back to UserJourneyView
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.7)]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.purple.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.bottom, 30)
            } else {
                // If no conditions are met, return EmptyView as the default
                EmptyView()
            }
        }
    }


    private func resultView(hrv: Double) -> some View {
        VStack(spacing: 15) {
            Text("ECG Measurement Complete")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.green)
            
            Text("Your HRV: \(String(format: "%.0f", hrv)) ms")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
        }
    }

    private func startECGMeasurement() {
        print("Start ECG Measurement")
        isLoading = true
        measurementStartTime = Date()
        voltageReadingsCount = 0
        showResults = false
        
        // Set a timeout handler. If data is not retrieved within 10 seconds, show notification.
        measurementTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { _ in
            DispatchQueue.main.async {
                // Show the notification
                self.showNotification = true
                
                // Automatically hide the notification after 3 seconds
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    DispatchQueue.main.async {
                        self.showNotification = false
                    }
                }
                
                // Reset measurement state after showing the notification
                self.measurementStatus = "Failed to retrieve data. Please try again."
                self.resetMeasurementState()
            }
        }
        
        print("Start Fetching Latest ECG Data")
        fetchLatestECG()
    }

    

    private func fetchLatestECG() {
        guard let startTime = measurementStartTime else {
            resetMeasurementState()
            return
        }
        
        healthKitManager.fetchLatestECG { ecg, error in
            if let ecg = ecg, ecg.startDate > startTime {
                // Process the retrieved ECG data
                healthKitManager.processECG(ecg, isPre: isPreMeditation) { date, voltageData, error in
                    DispatchQueue.main.async {
                        isLoading = false
                        measurementTimer?.invalidate()
                        if let error = error {
                            measurementStatus = "Error processing ECG: \(error.localizedDescription)"
                            resetMeasurementState()
                        } else {
                            voltageReadingsCount = voltageData.count
                            showResults = true
                            measurementStatus = "ECG processed successfully."
                            print("Total number of [timestamp, voltage] data points: \(voltageData.count)")
                            
                            // Prepare the data to be sent
                            let stage = determineStage()
                            let ecgDataPoints = voltageData.map { ECGDataPoint(timestamp: $0.0, voltage: $0.1) }
                            ecgMeasurementData = ECGMeasurementData(
                                userId: userId,
                                stage: stage,
                                ecgVoltage: ecgDataPoints,
                                time: Date()
                            )
                            
                            // Encode the full data set into JSON and print the size before chunking
                            do {
                                let encoder = JSONEncoder()
                                encoder.dateEncodingStrategy = .iso8601
                                if let ecgMeasurementData = ecgMeasurementData {
                                    let jsonData = try encoder.encode(ecgMeasurementData)
                                    print("Total size of ECG data before chunking: \(jsonData.count) bytes, or \(String(format: "%.2f", Double(jsonData.count) / 1024)) KB, or \(String(format: "%.4f", Double(jsonData.count) / 1024 / 1024)) MB")
                                }
                            } catch {
                                print("Error encoding ECG data: \(error.localizedDescription)")
                            }
                            
                            print("Start Data Chunking")
                            sendECGDataToServer()
                        }
                    }
                }
            } else {
                // If the data retrieval fails, try again after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.fetchLatestECG()
                }
            }
        }
    }

    
    private func determineStage() -> String {
        if isPreMeditation {
            return measurementCount == 1 ? "pre-1" : "pre-2"
        } else {
            return measurementCount == 1 ? "pos-1" : "pos-2"
        }
    }
    
    func sendECGDataToServer() {
        guard let ecgData = ecgMeasurementData else {
            print("No ECG data to send")
            return
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let jsonData = try encoder.encode(ecgData)
            
            guard let url = URL(string: apiUrl) else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            // Set timeout to 60 seconds
            request.timeoutInterval = 60

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("Error sending data: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Response status code: \(httpResponse.statusCode)")
                    if (200...299).contains(httpResponse.statusCode) {
                        print("Data sent successfully.")
                    } else {
                        print("Failed to send data. Server responded with status code: \(httpResponse.statusCode)")
                    }
                }
            }.resume()
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
    
    private func resetMeasurementState() {
        isLoading = false
        showResults = false
        measurementStartTime = nil
        voltageReadingsCount = 0
        measurementTimer?.invalidate()
    }
}

//struct ECGMeasurementView_Previews: PreviewProvider {
//    static var previews: some View {
//        ECGMeasurementView(isPreMeditation: .constant(true), userId: "1")
//            .environmentObject(HealthKitManager())
//    }
//}
