//
//  NetworkServiceTests.swift
//  CryptoCurrencyAssessmentTests
//
//  Created by Deepti Chawla on 11/11/25.
//

import XCTest

@testable import CryptoCurrencyAssessment

final class CryptoIntegrationTests: XCTestCase {
    var sut: NetworkService!

    override func setUp() {
        super.setUp()
        sut = NetworkService()
    }

    func testFetchTop5CryptosFromRealAPI() async throws {
        
        let endpoint = CryptoEndPoint.topFive // your real endpoint
        
    
        let result: [CryptoModel] = try await sut.request(endpoint, type: [CryptoModel].self)

   
        XCTAssertFalse(result.isEmpty, "Expected non-empty list of cryptos")
        XCTAssertNotNil(result.first?.name)
        XCTAssertNotNil(result.first?.current_price)
        print(" API Response: \(result.first?.name ?? "Unknown") - \(result.first?.current_price ?? 0)")
    }
}
