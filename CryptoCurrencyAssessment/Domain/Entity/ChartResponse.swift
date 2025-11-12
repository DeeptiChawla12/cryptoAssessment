//
// ChartResponse.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Foundation

/// This model decodes the JSON response containing historical price data
struct ChartResponse: Codable {
    let prices: [[Double]]
}
