//
//  DetailCryptoRepositoryProtocol.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Foundation

/// `DetailCryptoRepositoryProtocol` defines the contract for fetching
/// detailed market chart data of a specific cryptocurrency.
protocol DetailCryptoRepositoryProtocol {
    /// Fetches the market chart (historical price data) for a specific cryptocurrency.
    func fetchChart(for id: String) async throws -> [Double]
}
