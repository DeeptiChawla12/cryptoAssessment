//
//  FetchCryptoUseCases.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.
//

import Foundation


// MARK: - Protocol
/// A protocol that defines the fetching the top five cryptocurrencies.
protocol FetchTopFiveCryptoUseCaseProtocol {
    
    /// Fetches a list of the top five cryptocurrencies.
    /// Returns: An array of `CryptoModel` objects representing the top five cryptocurrencies.
    /// - Throws: An error if the network request, decoding, or repository operation fails.
    func fetchTopFiveCryptoList() async throws -> [CryptoModel]
}


// MARK: - Implementation


/// A concrete implementation of `FetchTopFiveCryptoUseCaseProtocol` that retrieves
/// cryptocurrency data from a repository.

class FetchCryptopFiveUseCases : FetchTopFiveCryptoUseCaseProtocol {
    
    /// The repository responsible for fetching cryptocurrency data.
    private let cryptoRepository: CryptoRepositoryProtocol
    
    // MARK: - Initializer
    
    /// Initializes the use case with a given cryptocurrency repository.
    init(cryptoRepository: CryptoRepositoryProtocol) {
        self.cryptoRepository = cryptoRepository
    }
    
    /// Fetches the top five cryptocurrencies by delegating to the repository layer.
    func fetchTopFiveCryptoList() async throws -> [CryptoModel] {
        try await cryptoRepository.fetchTopFive()
    }
    
}
