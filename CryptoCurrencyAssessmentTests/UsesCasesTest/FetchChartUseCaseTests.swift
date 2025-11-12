//
//  FetchChartUseCaseTests.swift
//  CryptoCurrencyAssessmentTests
//
//  Created by Deepti Chawla on 12/11/25.
//

import XCTest

@testable import CryptoCurrencyAssessment


final class FetchChartUseCaseTests: XCTestCase {
    
    
    
    var sut: FetchChartUseCase!
   private var mockRepository: MockDetailCryptoRepository!
    
   
    
    override func setUp() {
        super.setUp()
        mockRepository = MockDetailCryptoRepository()
        sut = FetchChartUseCase(detailrepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
   
    /// Tests successful chart data retrieval
    func test_execute_Success_ReturnsChartData() async throws {
        // Given
        let cryptoId = "bitcoin"
        let expectedPrices = DataFactoryTest.createChartPrices()
        mockRepository.setSuccessResponse(expectedPrices)
        
    
        let result = try await sut.execute(for: cryptoId)
        
       
        XCTAssertEqual(result.count, expectedPrices.count, "Should return correct number of price points")
        XCTAssertEqual(result, expectedPrices, "Should return expected price data")
        XCTAssertEqual(mockRepository.fetchChartCallCount, 1, "Repository should be called exactly once")
        XCTAssertEqual(mockRepository.lastRequestedId, cryptoId, "Should pass correct crypto ID to repository")
    }
    
   
    func test_execute_Success_DifferentCryptoIds() async throws {
      
        let testIds = ["bitcoin", "ethereum", "solana"]
        let expectedPrices = DataFactoryTest.createChartPrices()
        mockRepository.setSuccessResponse(expectedPrices)
        
        for testId in testIds {
           
            let result = try await sut.execute(for: testId)
            
           
            XCTAssertEqual(result.count, expectedPrices.count, "Should return data for \(testId)")
            XCTAssertEqual(mockRepository.lastRequestedId, testId, "Should track correct ID for \(testId)")
        }
        
        XCTAssertEqual(mockRepository.fetchChartCallCount, testIds.count, "Should call repository for each ID")
    }
    
   
    func test_execute_Success_EmptyChartData() async throws {
        
        let cryptoId = "unknown-coin"
        mockRepository.setSuccessResponse([])
        
       
        let result = try await sut.execute(for: cryptoId)
        
       
        XCTAssertTrue(result.isEmpty, "Should handle empty chart data")
        XCTAssertEqual(mockRepository.fetchChartCallCount, 1, "Repository should be called once")
    }
    
   
    func test_execute_NetworkError_ThrowsCorrectError() async {
        
        let cryptoId = "bitcoin"
        let expectedError = NetworkError.noInternet
        mockRepository.setFailureResponse(expectedError)
        
       
        do {
            _ = try await sut.execute(for: cryptoId)
            XCTFail("Should throw network error")
        } catch let error as NetworkError {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
            XCTAssertEqual(mockRepository.fetchChartCallCount, 1, "Repository should be called even on error")
        } catch {
            XCTFail("Should throw NetworkError, but threw: \(error)")
        }
    }
    
 
    func test_execute_InvalidCryptoId_ThrowsError() async {
       
        let invalidId = ""
        let expectedError = NetworkError.badURL
        mockRepository.setFailureResponse(expectedError)
        
       
        do {
            _ = try await sut.execute(for: invalidId)
            XCTFail("Should throw error for invalid ID")
        } catch let error as NetworkError {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        } catch {
            XCTFail("Should throw NetworkError, but threw: \(error)")
        }
    }
   
    func test_execute_ServerError_ThrowsCorrectError() async {
       
        let cryptoId = "bitcoin"
        let expectedError = NetworkError.invalidResponse(statusCode: 404)
        mockRepository.setFailureResponse(expectedError)
        
    
        do {
            _ = try await sut.execute(for: cryptoId)
            XCTFail("Should throw server error")
        } catch let error as NetworkError {
            if case .invalidResponse(let statusCode) = error {
                XCTAssertEqual(statusCode, 404, "Should preserve 404 status code")
            } else {
                XCTFail("Should throw invalidResponse error")
            }
        } catch {
            XCTFail("Should throw NetworkError, but threw: \(error)")
        }
    }
    

    func test_execute_ConcurrentRequests_HandledCorrectly() async throws {
        
        let cryptoIds = ["bitcoin", "ethereum", "solana"]
        let expectedPrices = DataFactoryTest.createChartPrices()
        mockRepository.setSuccessResponse(expectedPrices)
        
       
        let results = try await withThrowingTaskGroup(of: [Double].self) { group in
            for id in cryptoIds {
                group.addTask {
                    try await self.sut.execute(for: id)
                }
            }
            
            var allResults: [[Double]] = []
            for try await result in group {
                allResults.append(result)
            }
            return allResults
        }
        
       
        XCTAssertEqual(results.count, 3, "Should handle 3 concurrent requests")
        results.forEach { result in
            XCTAssertEqual(result.count, expectedPrices.count, "Each result should have correct data")
        }
        XCTAssertEqual(mockRepository.fetchChartCallCount, 3, "Repository should be called 3 times")
    }
}


private final class MockDetailCryptoRepository: DetailCryptoRepositoryProtocol {
    
    var shouldSucceed = true
    var mockData: [Double] = []
    var errorToThrow: NetworkError = .noInternet
    var fetchChartCallCount = 0
    var lastRequestedId: String?
    
    func fetchChart(for id: String) async throws -> [Double] {
        fetchChartCallCount += 1
        lastRequestedId = id
        
        // Simulate async delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        if !shouldSucceed {
            throw errorToThrow
        }
        
        return mockData
    }
    
    func setSuccessResponse(_ data: [Double]) {
        shouldSucceed = true
        mockData = data
    }
    
    func setFailureResponse(_ error: NetworkError) {
        shouldSucceed = false
        errorToThrow = error
    }
    
    func reset() {
        shouldSucceed = true
        mockData = []
        errorToThrow = .noInternet
        fetchChartCallCount = 0
        lastRequestedId = nil
    }
}
