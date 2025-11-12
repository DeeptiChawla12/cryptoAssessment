//
//  HomeViewModelTests.swift
//  CryptoCurrencyAssessmentTests
//
//  Created by Deepti Chawla on 12/11/25.
//

import XCTest
@testable import CryptoCurrencyAssessment


@MainActor
final class HomeViewModelTests: XCTestCase {
    
    
    var sut: HomeViewModel!
    private   var mockUseCase: MockFetchTopFiveCryptoUseCase!
    
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
    
    func test_initialState_SetsCorrectValues() {
        
        XCTAssertTrue(sut.fetchTopFivecryptos.isEmpty, "Initial crypto list should be empty")
        XCTAssertNil(sut.errorMessage, "Initial error message should be nil")
        XCTAssertFalse(sut.isLoading, "Initial loading state should be false")
        XCTAssertEqual(sut.totalValue, 0.0, "Initial total value should be 0")
    }
    
    
    func test_loadTopFive_Success_UpdatesStateCorrectly() async {
        
        let expectedCryptos = DataFactoryTest.createTopFiveCryptos()
        let expectedTotal = expectedCryptos.reduce(0) { $0 + ($1.current_price ?? 0) }
        mockUseCase.setSuccessResponse(expectedCryptos)
        
        
        await sut.loadTopFive()
        
        
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 5, "Should have 5 cryptocurrencies")
        XCTAssertEqual(sut.fetchTopFivecryptos.first?.id, "bitcoin", "First crypto should be Bitcoin")
        XCTAssertNil(sut.errorMessage, "Error message should be nil on success")
        XCTAssertFalse(sut.isLoading, "Loading should be false after completion")
        XCTAssertEqual(sut.totalValue, expectedTotal, accuracy: 0.01, "Total value should be calculated correctly")
        XCTAssertEqual(mockUseCase.fetchCallCount, 1, "Use case should be called exactly once")
    }
    
    
    func test_loadTopFive_LoadingState_UpdatesCorrectly() async {
        
        let expectedCryptos = DataFactoryTest.createTopFiveCryptos()
        mockUseCase.setSuccessResponse(expectedCryptos)
        mockUseCase.simulateDelay = true
        
        
        let loadingTask = Task { await sut.loadTopFive() }
        
        
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        
        XCTAssertTrue(sut.isLoading, "Should be loading during fetch")
        XCTAssertNil(sut.errorMessage, "Error message should be nil during loading")
        
        
        await loadingTask.value
        
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after completion")
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 5, "Should have loaded data")
    }
    
    func test_getAccountValue_CalculatesCorrectly() async {
        
        let customCryptos = [
            CryptoModel(id: "crypto1", current_price: 100.0),
            CryptoModel(id: "crypto2", current_price: 200.0),
            CryptoModel(id: "crypto3", current_price: 300.0)
        ]
        mockUseCase.setSuccessResponse(customCryptos)
        
        
        await sut.loadTopFive()
        
        
        XCTAssertEqual(sut.totalValue, 600.0, accuracy: 0.01, "Total should be 100 + 200 + 300 = 600")
    }
    
    func test_getAccountValue_HandlesNilPricesCorrectly() async {
        
        let customCryptos = [
            CryptoModel(id: "crypto1", current_price: 100.0),
            CryptoModel(id: "crypto2", current_price: nil),
            CryptoModel(id: "crypto3", current_price: 300.0)
        ]
        mockUseCase.setSuccessResponse(customCryptos)
        
        
        await sut.loadTopFive()
        
        
        XCTAssertEqual(sut.totalValue, 400.0, accuracy: 0.01, "Total should be 100 + 0 + 300 = 400")
    }
    
    
    func test_loadTopFive_NetworkError_UpdatesStateCorrectly() async {
        
        let expectedError = NetworkError.noInternet
        mockUseCase.setFailureResponse(expectedError)
        
        
        await sut.loadTopFive()
        
        
        XCTAssertTrue(sut.fetchTopFivecryptos.isEmpty, "Crypto list should remain empty on error")
        XCTAssertNotNil(sut.errorMessage, "Error message should be set")
        XCTAssertEqual(sut.errorMessage, expectedError.localizedDescription, "Should show correct error message")
        XCTAssertFalse(sut.isLoading, "Loading should be false after error")
        XCTAssertEqual(sut.totalValue, 0.0, "Total value should remain 0 on error")
    }
    
    func test_loadTopFive_ServerError_UpdatesStateCorrectly() async {
        
        let expectedError = NetworkError.invalidResponse(statusCode: 500)
        mockUseCase.setFailureResponse(expectedError)
        
        
        await sut.loadTopFive()
        
        
        XCTAssertTrue(sut.fetchTopFivecryptos.isEmpty, "Crypto list should remain empty on server error")
        XCTAssertNotNil(sut.errorMessage, "Error message should be set")
        XCTAssertFalse(sut.isLoading, "Loading should be false after error")
    }
    
    func test_loadTopFive_UnknownError_UpdatesStateCorrectly() async {
        
        let underlyingError = URLError(.cannotConnectToHost)
        mockUseCase.setUnknownError(underlyingError)
        
        
        await sut.loadTopFive()
        
        
        XCTAssertTrue(sut.fetchTopFivecryptos.isEmpty, "Crypto list should remain empty on unknown error")
        XCTAssertNotNil(sut.errorMessage, "Error message should be set")
        XCTAssertTrue(sut.errorMessage?.contains("Unexpected error") == true, "Should show unexpected error message")
        XCTAssertFalse(sut.isLoading, "Loading should be false after error")
    }
    
    func test_loadTopFive_ClearsErrorOnNewRequest() async {
        
        mockUseCase.setFailureResponse(.noInternet)
        await sut.loadTopFive()
        XCTAssertNotNil(sut.errorMessage, "Should have error message")
        
        
        let successData = DataFactoryTest.createTopFiveCryptos()
        mockUseCase.setSuccessResponse(successData)
        await sut.loadTopFive()
        
        
        XCTAssertNil(sut.errorMessage, "Error message should be cleared on new request")
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 5, "Should have loaded new data")
    }
    
    
    func test_loadTopFive_MultipleConsecutiveCalls_UpdatesCorrectly() async {
        // Given
        let firstData = [DataFactoryTest.createBitcoin()]
        let secondData = DataFactoryTest.createTopFiveCryptos()
        
        
        mockUseCase.setSuccessResponse(firstData)
        await sut.loadTopFive()
        
        
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 1, "Should have 1 item after first call")
        
        
        mockUseCase.setSuccessResponse(secondData)
        await sut.loadTopFive()
        
        
        XCTAssertEqual(sut.fetchTopFivecryptos.count, 5, "Should have 5 items after second call")
    }
}


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
