//import Foundation
//import HealthKit
//
//class ECGManager: ObservableObject {
//    @Published var message: String = ""
//    private let healthKitManager = HealthKitManager()
//    private let chunkSize = 500 // Adjust the chunk size as needed
//    var userId: String
//
//    init(userId: String) {
//        self.userId = userId
////        healthKitManager.requestAuthorization()
//    }
//
//    // Upload the most recent ECG data to the server in chunks
//    func uploadECGData(emotion: String, condition: String) {
//        healthKitManager.fetchMostRecentECGData { result in
//            switch result {
//            case .success(let (ecgSamples, startDate)):
//                print("Successfully fetched raw ECG data")
//
//                // Use the startDate from the most recent ECG measurement
//                let dateFormatter = ISO8601DateFormatter()
//                let startTimeString = dateFormatter.string(from: startDate)
//
//                // Split the sample into chunks and send
//                let chunks = self.splitIntoChunks(array: ecgSamples, chunkSize: self.chunkSize)
//                self.sendChunks(chunks, userId: self.userId, startTime: startTimeString, emotion: emotion, condition: condition)
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.message = "Failed to fetch ECG data: \(error.localizedDescription)"
//                    print(self.message)
//                }
//            }
//        }
//    }
//
//    // Helper function to split the data into chunks
//    private func splitIntoChunks<T>(array: [T], chunkSize: Int) -> [[T]] {
//        var chunks: [[T]] = []
//        for i in stride(from: 0, to: array.count, by: chunkSize) {
//            let end = Swift.min(i + chunkSize, array.count)
//            chunks.append(Array(array[i..<end]))
//        }
//        return chunks
//    }
//
//    // Send chunks sequentially
//    private func sendChunks(_ chunks: [[ECGSample]], userId: String, startTime: String, emotion: String, condition: String) {
//        guard !chunks.isEmpty else {
//            DispatchQueue.main.async {
//                self.message = "All chunks sent successfully"
//                print(self.message)
//            }
//            return
//        }
//
//        var remainingChunks = chunks
//        let currentChunk = remainingChunks.removeFirst()
//
//        let ecgRecord = ECGRecord(userId: userId, emotion: emotion, condition: condition, startTime: startTime, samples: currentChunk)
//        self.sendECGRecord(ecgRecord) { success in
//            if success {
//                self.sendChunks(remainingChunks, userId: userId, startTime: startTime, emotion: emotion, condition: condition)
//            } else {
//                DispatchQueue.main.async {
//                    self.message = "Failed to upload a chunk"
//                    print(self.message)
//                }
//            }
//        }
//    }
//
//    private func sendECGRecord(_ ecgRecord: ECGRecord, completion: @escaping (Bool) -> Void) {
//        do {
//            let jsonData = try JSONEncoder().encode(ecgRecord)
//            let dataSize = Double(jsonData.count) / 1024.0 / 1024.0 // Size in MB
//            print("ECG data chunk size: \(dataSize) MB")
//
//            // Heroku
//            guard let url = URL(string: "https://blooming-sierra-07593-40ab659c5b31.herokuapp.com/\(ecgRecord.userId)") else { return }
//            // AWS EB
////            guard let url = URL(string: "http://ecg-server-1.eba-fr58pb5n.us-east-1.elasticbeanstalk.com/\(ecgRecord.userId)") else { return }
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody = jsonData
//
//            print("Sending request to \(url)")
//            // print("JSON data being sent: \(String(data: jsonData, encoding: .utf8) ?? "N/A")")
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    DispatchQueue.main.async {
//                        self.message = "Failed to upload ECG record: \(error.localizedDescription)"
//                        print(self.message)
//                        completion(false)
//                    }
//                    return
//                }
//
//                if let response = response as? HTTPURLResponse {
//                    print("Response status code: \(response.statusCode)")
//                }
//
//                if let response = response as? HTTPURLResponse, response.statusCode == 201 {
//                    DispatchQueue.main.async {
//                        self.message = "ECG record uploaded successfully"
//                        print(self.message)
//                        completion(true)
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        self.message = "Failed to upload ECG record"
//                        print(self.message)
//                        completion(false)
//                    }
//                }
//            }.resume()
//        } catch {
//            self.message = "Failed to encode ECG record: \(error.localizedDescription)"
//            print(self.message)
//            completion(false)
//        }
//    }
//}

    // Send ECGRecord to AWS IoT Core
//    private func sendECGRecord(_ ecgRecord: ECGRecord, completion: @escaping (Bool) -> Void) {
//        do {
//            let jsonData = try JSONEncoder().encode(ecgRecord)
//            let dataSize = Double(jsonData.count) / 1024.0 / 1024.0 // Size in MB
//            print("ECG data chunk size: \(dataSize) MB")
//
//            let topic = "ecg/data/\(userId)"
//            let message = String(data: jsonData, encoding: .utf8)!
//
//            AWSIoTManager.shared.iotDataManager.publishString(message, onTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce) {
//                // Assuming publishString does not return success or error in the closure.
//                DispatchQueue.main.async {
//                    self.message = "ECG record uploaded successfully"
//                    print(self.message)
//                    completion(true)
//                }
//            }
//        } catch {
//            self.message = "Failed to encode ECG record: \(error.localizedDescription)"
//            print(self.message)
//            completion(false)
//        }
//    }
