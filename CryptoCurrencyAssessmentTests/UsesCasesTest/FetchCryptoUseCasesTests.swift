//
//  FetchCryptoUseCasesTests.swift
//  CryptoCurrencyAssessmentTests
//
//  Created by Deepti Chawla on 12/11/25.
//

import XCTest
@testable import CryptoCurrencyAssessment

/// Comprehensive test suite for FetchCryptopFiveUseCases
/// Tests the domain layer business logic in isolation using mocked dependencies
final class FetchCryptoUseCasesTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var sut: FetchCryptopFiveUseCases!
  private  var mockRepository: MockCryptoRepository!
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        mockRepository = MockCryptoRepository()
        sut = FetchCryptopFiveUseCases(cryptoRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Success Scenarios
    
    /// Tests successful retrieval of top five cryptocurrencies
    func test_fetchTopFiveCryptoList_Success_ReturnsCorrectData() async throws {
        // Given
        let expectedCryptos = DataFactoryTest.createTopFiveCryptos()
        mockRepository.setSuccessResponse(expectedCryptos)
        
        // When
        let result = try await sut.fetchTopFiveCryptoList()
        
        // Then
        XCTAssertEqual(result.count, 5, "Should return exactly 5 cryptocurrencies")
        XCTAssertEqual(result.first?.id, "bitcoin", "First crypto should be Bitcoin")
        XCTAssertEqual(result.first?.name, "Bitcoin", "First crypto name should be Bitcoin")
        XCTAssertEqual(mockRepository.fetchTopFiveCallCount, 1, "Repository should be called exactly once")
    }
    
    /// Tests that use case properly delegates to repository
    func test_fetchTopFiveCryptoList_Success_CallsRepository() async throws {
        // Given
        let testCryptos = DataFactoryTest.createTopFiveCryptos()
        mockRepository.setSuccessResponse(testCryptos)
        
        // When
        _ = try await sut.fetchTopFiveCryptoList()
        
        // Then
        XCTAssertEqual(mockRepository.fetchTopFiveCallCount, 1, "Should call repository exactly once")
    }
    
    /// Tests successful retrieval with empty data
    func test_fetchTopFiveCryptoList_Success_EmptyData() async throws {
        // Given
        mockRepository.setSuccessResponse([])
        
        // When
        let result = try await sut.fetchTopFiveCryptoList()
        
        // Then
        XCTAssertTrue(result.isEmpty, "Should return empty array when no data available")
        XCTAssertEqual(mockRepository.fetchTopFiveCallCount, 1, "Repository should be called once")
    }
    
    // MARK: - Error Scenarios
    
    /// Tests that network errors are properly propagated
    func test_fetchTopFiveCryptoList_NetworkError_ThrowsCorrectError() async {
        // Given
        let expectedError = NetworkError.noInternet
        mockRepository.setFailureResponse(expectedError)
        
        // When/Then
        do {
            _ = try await sut.fetchTopFiveCryptoList()
            XCTFail("Should throw network error")
        } catch let error as NetworkError {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
            XCTAssertEqual(mockRepository.fetchTopFiveCallCount, 1, "Repository should be called once even on error")
        } catch {
            XCTFail("Should throw NetworkError, but threw: \(error)")
        }
    }
    
    /// Tests handling of server errors
    func test_fetchTopFiveCryptoList_ServerError_ThrowsCorrectError() async {
        // Given
        let expectedError = NetworkError.invalidResponse(statusCode: 500)
        mockRepository.setFailureResponse(expectedError)
        
        // When/Then
        do {
            _ = try await sut.fetchTopFiveCryptoList()
            XCTFail("Should throw server error")
        } catch let error as NetworkError {
            if case .invalidResponse(let statusCode) = error {
                XCTAssertEqual(statusCode, 500, "Should preserve status code")
            } else {
                XCTFail("Should throw invalidResponse error")
            }
        } catch {
            XCTFail("Should throw NetworkError, but threw: \(error)")
        }
    }
    
    /// Tests handling of decoding errors
    func test_fetchTopFiveCryptoList_DecodingError_ThrowsCorrectError() async {
        // Given
        let expectedError = NetworkError.decodingError
        mockRepository.setFailureResponse(expectedError)
        
        // When/Then
        do {
            _ = try await sut.fetchTopFiveCryptoList()
            XCTFail("Should throw decoding error")
        } catch let error as NetworkError {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        } catch {
            XCTFail("Should throw NetworkError, but threw: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    
    /// Tests that multiple concurrent calls work correctly
    func test_fetchTopFiveCryptoList_ConcurrentCalls_HandledCorrectly() async throws {
        // Given
        let expectedCryptos = DataFactoryTest.createTopFiveCryptos()
        mockRepository.setSuccessResponse(expectedCryptos)
        
        // When - Make multiple concurrent calls
        async let result1 = sut.fetchTopFiveCryptoList()
        async let result2 = sut.fetchTopFiveCryptoList()
        async let result3 = sut.fetchTopFiveCryptoList()
        
        let results = try await [result1, result2, result3]
        
        // Then
        XCTAssertEqual(results.count, 3, "Should handle 3 concurrent calls")
        results.forEach { result in
            XCTAssertEqual(result.count, 5, "Each result should have 5 items")
            XCTAssertEqual(result.first?.id, "bitcoin", "Each result should start with Bitcoin")
        }
        XCTAssertEqual(mockRepository.fetchTopFiveCallCount, 3, "Repository should be called 3 times")
    }
}

// MARK: - Mock Repository

/// Mock implementation of CryptoRepositoryProtocol for use case testing
private final class MockCryptoRepository: CryptoRepositoryProtocol {
    
    var shouldSucceed = true
    var mockData: [CryptoModel] = []
    var errorToThrow: NetworkError = .noInternet
    var fetchTopFiveCallCount = 0
    
    func fetchTopFive() async throws -> [CryptoModel] {
        fetchTopFiveCallCount += 1
        
        // Simulate async delay
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        if !shouldSucceed {
            throw errorToThrow
        }
        
        return mockData
    }
    
    func setSuccessResponse(_ data: [CryptoModel]) {
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
        fetchTopFiveCallCount = 0
    }
}
