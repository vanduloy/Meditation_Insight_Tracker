//import Foundation
//import HealthKit
//
//class HealthKitManager: ObservableObject {
//    let healthStore = HKHealthStore()
//    
//    @Published var ppgHRVData: [(Date, Double)] = []
//    @Published var ecgHRVData: [(Date, Double, String)] = [] // (Date, HRV, Pre/Post-Med)
//    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
//    
//    private let ecgType = HKObjectType.electrocardiogramType()
//    
//    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
//        guard HKHealthStore.isHealthDataAvailable() else {
//            completion(false, nil)
//            return
//        }
//        
//        let typesToRead: Set<HKObjectType> = [
//            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
//            ecgType
//        ]
//        
//        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
//            DispatchQueue.main.async {
//                self.updateAuthorizationStatus()
//                completion(success, error)
//            }
//        }
//    }
//    
//    func updateAuthorizationStatus() {
//        guard let heartRateVariability = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
//            return
//        }
//
//        let hrvStatus = healthStore.authorizationStatus(for: heartRateVariability)
//        let ecgStatus = healthStore.authorizationStatus(for: ecgType)
//        
//        DispatchQueue.main.async {
//            self.authorizationStatus = (hrvStatus == .sharingAuthorized && ecgStatus == .sharingAuthorized) ? .sharingAuthorized : .notDetermined
//        }
//    }
//
//    
//    func fetchLatestECG(completion: @escaping (HKElectrocardiogram?, Error?) -> Void) {
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//        let query = HKSampleQuery(sampleType: ecgType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
//            guard let sample = samples?.first as? HKElectrocardiogram else {
//                completion(nil, error)
//                return
//            }
//            completion(sample, nil)
//        }
//        healthStore.execute(query)
//    }
//    
//    func processECG(_ ecg: HKElectrocardiogram, isPre: Bool, completion: @escaping (Date, [(TimeInterval, Double)], Error?) -> Void) {
//        var voltageData: [(TimeInterval, Double)] = []
//        let voltageQuery = HKElectrocardiogramQuery(ecg) { (query, result) in
//            switch result {
//            case .measurement(let measurement):
//                if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
//                    voltageData.append((measurement.timeSinceSampleStart, voltageQuantity.doubleValue(for: .volt())))
//                }
//            case .done:
//                print("Total ECG voltage measurements: \(voltageData.count)")
//
//                DispatchQueue.main.async {
//                    let medStatus = isPre ? "Pre-Med" : "Post-Med"
//                    self.ecgHRVData.append((ecg.startDate, 0, medStatus)) // Set HRV to 0, if needed
//                    self.ecgHRVData.sort { $0.0 > $1.0 }
//                    completion(ecg.startDate, voltageData, nil)
//                }
//            case .error(let error):
//                completion(ecg.startDate, [], error)
//            @unknown default:
//                print("Unknown Error")
//            }
//        }
//        healthStore.execute(voltageQuery)
//    }
//
//    
//    private func prepareDataForCloud(userId: String, startTime: Date, voltageData: [(TimeInterval, Double)], calculatedHRV: Double) -> [String: Any] {
//        return [
//            "userId": userId,
//            "startTime": startTime,
//            "voltageData": voltageData.map { ["timeInterval": $0.0, "voltage": $0.1] },
//            "calculatedHRV": calculatedHRV
//        ]
//    }
//    
//    func fetchPPGHRVData(completion: @escaping (Bool, Error?) -> Void) {
//        guard let heartRateVariability = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
//            completion(false, nil)
//            return
//        }
//        
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//        let query = HKSampleQuery(sampleType: heartRateVariability,
//                                  predicate: nil,
//                                  limit: HKObjectQueryNoLimit,
//                                  sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
//            if let error = error {
//                completion(false, error)
//                return
//            }
//            
//            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
//                DispatchQueue.main.async {
//                    self?.ppgHRVData = []
//                    completion(true, nil)
//                }
//                return
//            }
//            
//            DispatchQueue.main.async {
//                self?.ppgHRVData = samples.map { (sample) -> (Date, Double) in
//                    let hrvValue = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
//                    return (sample.startDate, hrvValue)
//                }
//                completion(true, nil)
//            }
//        }
//        
//        healthStore.execute(query)
//    }
//}

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var ppgHRVData: [(Date, Double)] = []
    @Published var ecgHRVData: [(Date, Double, String)] = []
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    private let ecgType = HKObjectType.electrocardiogramType()
    
    // 请求授权的方法
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            ecgType
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.updateAuthorizationStatus() // 调用保持原名的 updateAuthorizationStatus
                completion(success, error)
            }
        }
    }
    
    // 更新授权状态
    func updateAuthorizationStatus() {
        guard let heartRateVariability = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return
        }
        
        // 获取 HRV 和 ECG 授权状态
        let hrvStatus = healthStore.authorizationStatus(for: heartRateVariability)
        let ecgStatus = healthStore.authorizationStatus(for: ecgType)
        
        // 根据 HRV 和 ECG 的状态更新 `authorizationStatus`
        DispatchQueue.main.async {
            self.authorizationStatus = (hrvStatus == .sharingAuthorized && ecgStatus == .sharingAuthorized) ? .sharingAuthorized : .notDetermined
        }
    }
    
    // 获取最新的 ECG 数据
    func fetchLatestECG(completion: @escaping (HKElectrocardiogram?, Error?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: ecgType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let sample = samples?.first as? HKElectrocardiogram else {
                completion(nil, error)
                return
            }
            completion(sample, nil)
        }
        healthStore.execute(query)
    }
    
    // 处理 ECG 数据
    func processECG(_ ecg: HKElectrocardiogram, isPre: Bool, completion: @escaping (Date, [(TimeInterval, Double)], Error?) -> Void) {
        var voltageData: [(TimeInterval, Double)] = []
        let voltageQuery = HKElectrocardiogramQuery(ecg) { [weak self] (query, result) in
            guard let self = self else { return }
            
            switch result {
            case .measurement(let measurement):
                if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                    voltageData.append((measurement.timeSinceSampleStart, voltageQuantity.doubleValue(for: .volt())))
                }
            case .done:
                let medStatus = isPre ? "Pre-Med" : "Post-Med"
                DispatchQueue.main.async {
                    self.ecgHRVData.append((ecg.startDate, 0, medStatus)) // Set HRV to 0 if needed
                    self.ecgHRVData.sort { $0.0 > $1.0 }
                    completion(ecg.startDate, voltageData, nil)
                }
            case .error(let error):
                completion(ecg.startDate, [], error)
            @unknown default:
                print("Unknown Error")
            }
        }
        healthStore.execute(voltageQuery)
    }
    
    // 获取 PPG HRV 数据
    func fetchPPGHRVData(completion: @escaping (Bool, Error?) -> Void) {
        guard let heartRateVariability = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion(false, nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateVariability,
                                  predicate: nil,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                DispatchQueue.main.async {
                    self?.ppgHRVData = []
                    completion(true, nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.ppgHRVData = samples.map { (sample) -> (Date, Double) in
                    let hrvValue = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                    return (sample.startDate, hrvValue)
                }
                completion(true, nil)
            }
        }
        
        healthStore.execute(query)
    }
}
