//
//  IoTManager.swift
//  MIT
//
//  Created by Richard C. on 7/19/24.
//

//import Foundation
//
//class IoTManager {
//    static let shared = IoTManager()
//
//    private init() {}
//
//    func uploadData(data: [String: Any], completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: "http://10.0.0.212:8888/upload") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
//            request.httpBody = jsonData
//        } catch {
//            print("Error serializing JSON: \(error)")
//            completion(false)
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error uploading data: \(error)")
//                completion(false)
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                print("Data uploaded successfully")
//                completion(true)
//            } else {
//                print("Error with response: \(String(describing: response))")
//                completion(false)
//            }
//        }
//
//        task.resume()
//    }
//}
