//
//  CryptoCacheManager.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Foundation
import Cache


//
//  CacheManager.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Foundation
import Cache

// MARK: - Protocol
//
//  CacheManager.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Foundation
import Cache

// MARK: - Protocol
/// A protocol defining caching operations for cryptocurrency data.
/// This protocol provides methods to save and retrieve cached data,
protocol CacheManagerProtocol {
    func get(forKey key: String) -> [CryptoModel]?
    func save(_ data: [CryptoModel], forKey key: String)

}

// MARK: - Implementation
final class CacheManager: CacheManagerProtocol {
    
    private let storage: Storage<String, [CryptoModel]>
    
    /// The expiry duration for cached data (1 day).
    private let expiry: Expiry = .seconds(24 * 60 * 60) //  1 day
    
    init() {
        // Disk configuration (persistent cache)
        let diskConfig = DiskConfig(name: AppConstants.CacheKeys.cryptoAPICache, expiry: expiry)
        
        // Memory configuration (in-memory cache for fast access)
        let memoryConfig = MemoryConfig(expiry: expiry, countLimit: 100)
        
        // Custom transformer for [CryptoModel]
        let transformer = TransformerFactory.forCodable(ofType: [CryptoModel].self)
        
        storage = try! Storage<String, [CryptoModel]>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: transformer
        )
    }
    
    /// Retrieves cached cryptocurrency data for a given key.
    func get(forKey key: String) -> [CryptoModel]? {
        try? storage.object(forKey: key)
    }
    
    /// Saves cryptocurrency data into the cache for a given key.
    ///   - data: The array of `CryptoModel` to be stored.
    ///   - key: The unique key used to identify cached data.
    
    func save(_ data: [CryptoModel], forKey key: String) {
        try? storage.setObject(data, forKey: key, expiry: expiry)
    }
    
   
}
