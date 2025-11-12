//
//  HomeViewModelTests.swift
//  CryptoCurrencyAssessmentTests
//
//  Created by Deepti Chawla on 12/11/25.
//

import XCTest
@testable import CryptoCurrencyAssessment

/// Comprehensive test suite for HomeViewModel
/// Tests UI state management and business logic integration
@MainActor
final class HomeViewModelTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var sut: HomeViewModel!
 private   var mockUseCase: MockFetchTopFiveCryptoUseCase!
    
    // MARK: - Test Lifecycle
    
    override func setUp() async throws {
        try await super.setUp()
        mockUseCase = MockFetchTopFiveCryptoUseCase()
        sut = HomeViewModel(fetchCryptoUseCase: mockUseCase)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockUseCase = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    /// Tests initial state of the view model
    func test_initialState_SetsCorrectValues() {
        // Then
        XCTAssertTrue(sut.fetchTopFivecryptos.isEmpty, "Initial crypto list should be empty")
        XCTAssertNil(sut.errorMessage, "Initial error message should be nil")
        XCTAssertFalse(sut.isLoading, "Initial loading state should be false")
        XCTAssertEqual(sut.totalValue, 0.0, "Initial total value should be 0")
    }
    
    // MARK: - Success Scenarios
    
    /// Tests successful data loading updates state correctly
    func test_loadTopFive_Success_UpdatesStateCorrectly() async {
        // Given
        let expectedCryptos = DataFactoryTest.createTopFiveCryptos()
        let expectedTotal = expectedCryptos.reduce(0) { $0 + ($1.current_price ?? 0) }
        mockUseCase.setSuccessResponse(expectedCryptos)
        
        // When
        await sut.loadTopFive()
        
        // Then
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 5, "Should have 5 cryptocurrencies")
        XCTAssertEqual(sut.fetchTopFivecryptos.first?.id, "bitcoin", "First crypto should be Bitcoin")
        XCTAssertNil(sut.errorMessage, "Error message should be nil on success")
        XCTAssertFalse(sut.isLoading, "Loading should be false after completion")
        XCTAssertEqual(sut.totalValue, expectedTotal, accuracy: 0.01, "Total value should be calculated correctly")
        XCTAssertEqual(mockUseCase.fetchCallCount, 1, "Use case should be called exactly once")
    }
    
    /// Tests loading state management during data fetch
    func test_loadTopFive_LoadingState_UpdatesCorrectly() async {
        // Given
        let expectedCryptos = DataFactoryTest.createTopFiveCryptos()
        mockUseCase.setSuccessResponse(expectedCryptos)
        mockUseCase.simulateDelay = true
        
        // When - Start loading
        let loadingTask = Task { await sut.loadTopFive() }
        
        // Give a moment for loading to start
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        // Then - Check loading state
        XCTAssertTrue(sut.isLoading, "Should be loading during fetch")
        XCTAssertNil(sut.errorMessage, "Error message should be nil during loading")
        
        // Wait for completion
        await loadingTask.value
        
        // Then - Check final state
        XCTAssertFalse(sut.isLoading, "Should not be loading after completion")
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 5, "Should have loaded data")
    }
    
    /// Tests total value calculation with different price scenarios
    func test_getAccountValue_CalculatesCorrectly() async {
        // Given - Custom crypto data with known prices
        let customCryptos = [
            CryptoModel(id: "crypto1", current_price: 100.0),
            CryptoModel(id: "crypto2", current_price: 200.0),
            CryptoModel(id: "crypto3", current_price: 300.0)
        ]
        mockUseCase.setSuccessResponse(customCryptos)
        
        // When
        await sut.loadTopFive()
        
        // Then
        XCTAssertEqual(sut.totalValue, 600.0, accuracy: 0.01, "Total should be 100 + 200 + 300 = 600")
    }
    
    /// Tests total value calculation with nil prices
    func test_getAccountValue_HandlesNilPricesCorrectly() async {
        // Given - Crypto data with some nil prices
        let customCryptos = [
            CryptoModel(id: "crypto1", current_price: 100.0),
            CryptoModel(id: "crypto2", current_price: nil),
            CryptoModel(id: "crypto3", current_price: 300.0)
        ]
        mockUseCase.setSuccessResponse(customCryptos)
        
        // When
        await sut.loadTopFive()
        
        // Then
        XCTAssertEqual(sut.totalValue, 400.0, accuracy: 0.01, "Total should be 100 + 0 + 300 = 400")
    }
    
    // MARK: - Error Scenarios
    
    /// Tests network error handling
    func test_loadTopFive_NetworkError_UpdatesStateCorrectly() async {
        // Given
        let expectedError = NetworkError.noInternet
        mockUseCase.setFailureResponse(expectedError)
        
        // When
        await sut.loadTopFive()
        
        // Then
        XCTAssertTrue(sut.fetchTopFivecryptos.isEmpty, "Crypto list should remain empty on error")
        XCTAssertNotNil(sut.errorMessage, "Error message should be set")
        XCTAssertEqual(sut.errorMessage, expectedError.localizedDescription, "Should show correct error message")
        XCTAssertFalse(sut.isLoading, "Loading should be false after error")
        XCTAssertEqual(sut.totalValue, 0.0, "Total value should remain 0 on error")
    }
    
    /// Tests server error handling
    func test_loadTopFive_ServerError_UpdatesStateCorrectly() async {
        // Given
        let expectedError = NetworkError.invalidResponse(statusCode: 500)
        mockUseCase.setFailureResponse(expectedError)
        
        // When
        await sut.loadTopFive()
        
        // Then
        XCTAssertTrue(sut.fetchTopFivecryptos.isEmpty, "Crypto list should remain empty on server error")
        XCTAssertNotNil(sut.errorMessage, "Error message should be set")
        XCTAssertFalse(sut.isLoading, "Loading should be false after error")
    }
    
    /// Tests unknown error handling
    func test_loadTopFive_UnknownError_UpdatesStateCorrectly() async {
        // Given
        let underlyingError = URLError(.cannotConnectToHost)
        mockUseCase.setUnknownError(underlyingError)
        
        // When
        await sut.loadTopFive()
        
        // Then
        XCTAssertTrue(sut.fetchTopFivecryptos.isEmpty, "Crypto list should remain empty on unknown error")
        XCTAssertNotNil(sut.errorMessage, "Error message should be set")
        XCTAssertTrue(sut.errorMessage?.contains("Unexpected error") == true, "Should show unexpected error message")
        XCTAssertFalse(sut.isLoading, "Loading should be false after error")
    }
    
    // MARK: - State Persistence Tests
    
    /// Tests that error state is cleared on new request
    func test_loadTopFive_ClearsErrorOnNewRequest() async {
        // Given - First request fails
        mockUseCase.setFailureResponse(.noInternet)
        await sut.loadTopFive()
        XCTAssertNotNil(sut.errorMessage, "Should have error message")
        
        // When - Second request succeeds
        let successData = DataFactoryTest.createTopFiveCryptos()
        mockUseCase.setSuccessResponse(successData)
        await sut.loadTopFive()
        
        // Then
        XCTAssertNil(sut.errorMessage, "Error message should be cleared on new request")
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 5, "Should have loaded new data")
    }
    
    /// Tests multiple consecutive calls
    func test_loadTopFive_MultipleConsecutiveCalls_UpdatesCorrectly() async {
        // Given
        let firstData = [DataFactoryTest.createBitcoin()]
        let secondData = DataFactoryTest.createTopFiveCryptos()
        
        // When - First call
        mockUseCase.setSuccessResponse(firstData)
        await sut.loadTopFive()
        
        // Then
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 1, "Should have 1 item after first call")
        
        // When - Second call
        mockUseCase.setSuccessResponse(secondData)
        await sut.loadTopFive()
        
        // Then
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 5, "Should have 5 items after second call")
    }
}

// MARK: - Mock Use Case

/// Mock implementation of FetchTopFiveCryptoUseCaseProtocol for ViewModel testing
private final class MockFetchTopFiveCryptoUseCase: FetchTopFiveCryptoUseCaseProtocol {
    
    var shouldSucceed = true
    var mockData: [CryptoModel] = []
    var errorToThrow: NetworkError = .noInternet
    var unknownError: Error?
    var fetchCallCount = 0
    var simulateDelay = false
    
    func fetchTopFiveCryptoList() async throws -> [CryptoModel] {
        fetchCallCount += 1
        
        if simulateDelay {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        if let unknownError = unknownError {
            throw unknownError
        }
        
        if !shouldSucceed {
            throw errorToThrow
        }
        
        return mockData
    }
    
    func setSuccessResponse(_ data: [CryptoModel]) {
        shouldSucceed = true
        mockData = data
        unknownError = nil
    }
    
    func setFailureResponse(_ error: NetworkError) {
        shouldSucceed = false
        errorToThrow = error
        unknownError = nil
    }
    
    func setUnknownError(_ error: Error) {
        unknownError = error
        shouldSucceed = true // This will be overridden by the unknown error
    }
    
    func reset() {
        shouldSucceed = true
        mockData = []
        errorToThrow = .noInternet
        unknownError = nil
        fetchCallCount = 0
        simulateDelay = false
    }
}
