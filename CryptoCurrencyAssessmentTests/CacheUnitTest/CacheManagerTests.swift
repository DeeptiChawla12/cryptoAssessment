//
//  CacheManagerTests.swift
//  CryptoCurrencyAssessmentTests
//
//  Created by Deepti Chawla on 11/11/25.
//

import XCTest
@testable import CryptoCurrencyAssessment


final class CacheManagerTests: XCTestCase {
    
    var cacheManager: CacheManager!
    let testKey = "test_cryptos"
    var sampleCryptos: [CryptoModel]!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager()
        
        // Dummy sample data (matching your CryptoModel)
        sampleCryptos = [
            CryptoModel(id: "bitcoin", symbol: "btc", name: "Bitcoin", image: "", current_price: 0, market_cap: 1.2),
            CryptoModel(id: "ethereum", symbol: "eth", name: "Ethereum", image: "", current_price: 0, market_cap: -0.5)
        ]
    }
    
    override func tearDown() {
        cacheManager = nil
        sampleCryptos = nil
        super.tearDown()
    }
    
    func test_SaveAndGet_CachedData() {
        // Save data
        cacheManager.save(sampleCryptos, forKey: testKey)
        
        // Retrieve data
        let cached = cacheManager.get(forKey: testKey)
        
        //  Assertions
        XCTAssertNotNil(cached, "Cache should contain saved data")
        XCTAssertEqual(cached?.count, sampleCryptos.count)
        XCTAssertEqual(cached?.first?.id, "bitcoin")
        XCTAssertEqual(cached?.last?.symbol, "eth")
    }
    
    func test_Clear_RemovesCachedData() {
        //  Save data
        cacheManager.save(sampleCryptos, forKey: testKey)
        XCTAssertNotNil(cacheManager.get(forKey: testKey))
        
     
        //  Ensure cache is empty
        let cachedAfterClear = cacheManager.get(forKey: testKey)
        XCTAssertNil(cachedAfterClear, "Cache should be empty after clearing")
    }
    
    func test_OverwriteExistingCache() {
        // Save initial data
        cacheManager.save(sampleCryptos, forKey: testKey)
        
        //  Overwrite with new data
        let newCryptos = [
            CryptoModel(id: "dogecoin", symbol: "doge", name: "Dogecoin", image:"", current_price: 0, market_cap: 10.0)
        ]
        cacheManager.save(newCryptos, forKey: testKey)
        
        // Fetch new data
        let cached = cacheManager.get(forKey: testKey)
        XCTAssertEqual(cached?.count, 1)
        XCTAssertEqual(cached?.first?.id, "dogecoin", "New cache should replace old one")
    }
}


