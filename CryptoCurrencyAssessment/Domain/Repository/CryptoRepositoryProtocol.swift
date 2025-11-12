//
//  CryptoRepositoryProtocol.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.
//

import Foundation

/// A repository protocol that defines methods for accessing cryptocurrency data.
/// The `CryptoRepositoryProtocol` serves as an abstraction layer between the
/// domain and data layers.
protocol CryptoRepositoryProtocol{
    /// Fetches a list of the top five cryptocurrencies.
    ///
    /// This method is asynchronous and may perform a network request or
    /// retrieve data from a local cache, depending on the implementation.
    func fetchTopFive() async throws -> [CryptoModel]
}
