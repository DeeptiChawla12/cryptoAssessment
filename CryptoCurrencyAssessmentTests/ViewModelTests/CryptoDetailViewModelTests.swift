//
//  CryptoDetailViewModelTests.swift
//  CryptoCurrencyAssessmentTests
//
//  Created by Deepti Chawla on 12/11/25.
//

import XCTest
@testable import CryptoCurrencyAssessment

@MainActor
final class CryptoDetailViewModelTests: XCTestCase {
    
    
    
    var sut: CryptoDetailViewModel!
    private var mockUseCase: MockFetchChartUseCase!
    
    
    
    override func setUp() async throws {
        try await super.setUp()
        mockUseCase = MockFetchChartUseCase()
        sut = CryptoDetailViewModel(fetchChartUseCase: mockUseCase)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockUseCase = nil
        try await super.tearDown()
    }
    
    
    func test_initialState_SetsCorrectValues() {
        
        XCTAssertTrue(sut.prices.isEmpty, "Initial prices should be empty")
        XCTAssertFalse(sut.isLoading, "Initial loading state should be false")
        XCTAssertNil(sut.errorMessage, "Initial error message should be nil")
    }
    
    
    func test_fetchChartData_Success_UpdatesStateCorrectly() async {
        
        let cryptoId = "bitcoin"
        let expectedPrices = DataFactoryTest.createChartPrices()
        mockUseCase.setSuccessResponse(expectedPrices)
        
        
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertEqual(sut.prices, expectedPrices, "Prices should match expected data")
        XCTAssertNil(sut.errorMessage, "Error message should be nil on success")
        XCTAssertFalse(sut.isLoading, "Loading should be false after completion")
        XCTAssertEqual(mockUseCase.executeCallCount, 1, "Use case should be called exactly once")
        XCTAssertEqual(mockUseCase.lastRequestedId, cryptoId, "Should pass correct ID to use case")
    }
    
    
    func test_fetchChartData_LoadingState_UpdatesCorrectly() async {
        
        let cryptoId = "bitcoin"
        let expectedPrices = DataFactoryTest.createChartPrices()
        mockUseCase.setSuccessResponse(expectedPrices)
        mockUseCase.simulateDelay = true
        
        // Start loading
        let loadingTask = Task { await sut.fetchChartData(for: cryptoId) }
        
        // Give a moment for loading to start
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        // Check loading state
        XCTAssertTrue(sut.isLoading, "Should be loading during fetch")
        XCTAssertNil(sut.errorMessage, "Error message should be nil during loading")
        
        // Wait for completion
        await loadingTask.value
        
        // Check final state
        XCTAssertFalse(sut.isLoading, "Should not be loading after completion")
        XCTAssertEqual(sut.prices.count, expectedPrices.count, "Should have loaded price data")
    }
    
    
    func test_fetchChartData_DifferentCryptoIds_HandledCorrectly() async {
        
        let testIds = ["bitcoin", "ethereum", "solana"]
        let expectedPrices = DataFactoryTest.createChartPrices()
        mockUseCase.setSuccessResponse(expectedPrices)
        
        for (index, cryptoId) in testIds.enumerated() {
            
            await sut.fetchChartData(for: cryptoId)
            
            
            XCTAssertEqual(sut.prices, expectedPrices, "Should load data for \(cryptoId)")
            XCTAssertEqual(mockUseCase.lastRequestedId, cryptoId, "Should track correct ID for \(cryptoId)")
            XCTAssertEqual(mockUseCase.executeCallCount, index + 1, "Should increment call count for each request")
        }
    }
    
    
    func test_fetchChartData_EmptyData_HandledCorrectly() async {
        
        let cryptoId = "unknown-coin"
        mockUseCase.setSuccessResponse([])
        
        
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertTrue(sut.prices.isEmpty, "Prices should remain empty")
        XCTAssertNil(sut.errorMessage, "Error message should be nil for empty data")
        XCTAssertFalse(sut.isLoading, "Loading should be false")
    }
    
    
    func test_fetchChartData_NetworkError_UpdatesStateCorrectly() async {
        
        let cryptoId = "bitcoin"
        let expectedError = "No internet connection. Please check your network and try again."
        mockUseCase.setFailureResponse(.noInternet)
        
        
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertTrue(sut.prices.isEmpty, "Prices should remain empty on error")
        
        XCTAssertFalse(sut.isLoading, "Loading should be false after error")
    }
    
    
    func test_fetchChartData_ServerError_UpdatesStateCorrectly() async {
        
        let cryptoId = "bitcoin"
        mockUseCase.setFailureResponse(.invalidResponse(statusCode: 404))
        
        
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertTrue(sut.prices.isEmpty, "Prices should remain empty on server error")
        XCTAssertNotNil(sut.errorMessage, "Error message should be set")
        XCTAssertTrue(sut.errorMessage?.contains("404") == true, "Should show 404 error")
        XCTAssertFalse(sut.isLoading, "Loading should be false after error")
    }
    
    
    func test_fetchChartData_DecodingError_UpdatesStateCorrectly() async {
        
        let cryptoId = "bitcoin"
        mockUseCase.setFailureResponse(.decodingError)
        
        
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertTrue(sut.prices.isEmpty, "Prices should remain empty on decoding error")
        XCTAssertNotNil(sut.errorMessage, "Error message should be set")
        
        
        
        XCTAssertFalse(sut.isLoading, "Loading should be false after error")
    }
    
    
    func test_fetchChartData_ClearsErrorOnNewRequest() async {
        
        let cryptoId = "bitcoin"
        mockUseCase.setFailureResponse(.noInternet)
        await sut.fetchChartData(for: cryptoId)
        XCTAssertNotNil(sut.errorMessage, "Should have error message")
        
        
        let successData = DataFactoryTest.createChartPrices()
        mockUseCase.setSuccessResponse(successData)
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertNil(sut.errorMessage, "Error message should be cleared on new request")
        XCTAssertEqual(sut.prices, successData, "Should have loaded new data")
    }
    
    
    func test_fetchChartData_MultipleConsecutiveCalls_UpdatesCorrectly() async {
        
        let cryptoId = "bitcoin"
        let firstData = [100.0, 200.0, 300.0]
        let secondData = DataFactoryTest.createChartPrices()
        
        
        mockUseCase.setSuccessResponse(firstData)
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertEqual(sut.prices, firstData, "Should have first data set")
        
        
        mockUseCase.setSuccessResponse(secondData)
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertEqual(sut.prices, secondData, "Should have second data set")
        XCTAssertEqual(mockUseCase.executeCallCount, 2, "Should have made 2 calls")
    }
    
    
    func test_fetchChartData_LargeDataset_HandledCorrectly() async {
        
        let cryptoId = "bitcoin"
        let largePriceData = Array(repeating: 50000.0, count: 1000) // 1000 price points
        mockUseCase.setSuccessResponse(largePriceData)
        
        
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertEqual(sut.prices.count, 1000, "Should handle large datasets")
        XCTAssertNil(sut.errorMessage, "Should not have error for large dataset")
        XCTAssertFalse(sut.isLoading, "Loading should complete for large dataset")
    }
    
    
    func test_fetchChartData_ExtremePriceValues_HandledCorrectly() async {
        
        let cryptoId = "bitcoin"
        let extremePrices = [0.0, Double.greatestFiniteMagnitude, -1000.0, 0.000001]
        mockUseCase.setSuccessResponse(extremePrices)
        
        
        await sut.fetchChartData(for: cryptoId)
        
        
        XCTAssertEqual(sut.prices, extremePrices, "Should handle extreme price values")
        XCTAssertNil(sut.errorMessage, "Should not have error for extreme values")
    }
}


private final class MockFetchChartUseCase: FetchChartUseCaseProtocol {
    
    var shouldSucceed = true
    var mockData: [Double] = []
    var errorToThrow: Error = NetworkError.noInternet
    var executeCallCount = 0
    var lastRequestedId: String?
    var simulateDelay = false
    
    func execute(for id: String) async throws -> [Double] {
        executeCallCount += 1
        lastRequestedId = id
        
        if simulateDelay {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
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
        errorToThrow = NetworkError.noInternet
        executeCallCount = 0
        lastRequestedId = nil
        simulateDelay = false
    }
}
