//
//  ECGData.swift
//  MIT
//
//  Created by Richard C. on 7/20/24.
//

import Foundation

struct ECGSample: Codable {
    let time: TimeInterval
    let voltage: Double
}

struct ECGRecord: Codable {
    let userId: String
    let emotion: String
    let condition: String
    let startTime: String
    let samples: [ECGSample]
}


