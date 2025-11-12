//
//  CryptoRepositoryImpl.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.
//

import Foundation

/// A concrete implementation of `CryptoRepositoryProtocol` responsible for
/// fetching cryptocurrency data from a remote API and caching it locally.

class CryptoRepositoryImpl : CryptoRepositoryProtocol {
    private let  networkService : NetworkServiceProtocol
    private let cacheManager : CacheManager
    init(networkService: NetworkServiceProtocol, cacheManager: CacheManager = CacheManager()) {
        self.networkService = networkService
        self.cacheManager = cacheManager
    }
    func fetchTopFive() async throws -> [CryptoModel] {
        
        // Construct the endpoint URL
        guard let url = CryptoEndPoint.topFive.url else {
            throw URLError(.badURL)
        }
        
        let cacheKey = url.relativePath
        
        //Try fetching from cache
        if let cached = cacheManager.get(forKey: cacheKey) {
            return cached
        }
        
        //Fetch from network if cache not found
        let topFiveResponse  = try await networkService.request(CryptoEndPoint.topFive, type: [CryptoModel].self)
        
        
        // Save to cache
        cacheManager.save(topFiveResponse, forKey: cacheKey)
        return topFiveResponse
    }
    
    
}
