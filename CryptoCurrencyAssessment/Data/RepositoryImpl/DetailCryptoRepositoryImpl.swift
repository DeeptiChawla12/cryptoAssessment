//
//  DetailCryptoRepositoryImpl.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Foundation

// MARK: - Repository Implementation
// This class handles fetching detailed crypto data (like market charts)
class DetailCryptoRepositoryImpl: DetailCryptoRepositoryProtocol {
   
    
     
     // Network service responsible for performing API requests.
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchChart(for id: String) async throws -> [Double] {
        // Here, we're fetching data for the last 7 days.
        let endpoint = CryptoEndPoint.marketChart(id: id, days: 7)
        // Pass endpoint itself, not endpoint.url
        let response = try await networkService.request(endpoint, type: ChartResponse.self)
        return response.prices.map { $0[1] }
    }
}
