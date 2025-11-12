//
//  FetchChartUseCaseProtocol.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Foundation

/// `FetchChartUseCaseProtocol` defines the contract for fetching
/// /// historical chart data (such as price trends) for a specific cryptocurrency.

protocol FetchChartUseCaseProtocol {
    // Executes the use case to fetch chart data for a given cryptocurrency.
    func execute(for id: String) async throws -> [Double]
}

final class FetchChartUseCase: FetchChartUseCaseProtocol {
    private let detailrepository: DetailCryptoRepositoryProtocol

    /// Initializes the use case with a repository dependency.
    init(detailrepository: DetailCryptoRepositoryProtocol) {
        self.detailrepository = detailrepository
    }
    
    /// Executes the operation to fetch chart data by delegating to the repository layer.

    func execute(for id: String) async throws -> [Double] {
        try await detailrepository.fetchChart(for: id)
    }
}
