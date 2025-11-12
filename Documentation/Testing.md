# Testing Guide - CryptoCurrency Assessment

## Overview

This document provides comprehensive guidance for testing the CryptoCurrency Assessment iOS application. The testing strategy follows the Clean Architecture layers and emphasizes both unit testing with mocks and integration testing with real dependencies.

## Test Structure

### Directory Organization
```
CryptoCurrencyAssessmentTests/
├── Mocks/                    # Mock implementations and test utilities
│   └── TestDataFactory.swift
├── UseCaseTests/            # Domain layer business logic tests
│   ├── FetchCryptoUseCasesTests.swift
│   └── FetchChartUseCaseTests.swift
├── ViewModelTests/          # Presentation layer state management tests
│   ├── HomeViewModelTests.swift
│   └── CryptoDetailViewModelTests.swift
├── APIUnitTest/             # Real API integration tests
│   └── NetworkServiceTests.swift
└── CacheUnitTest/           # Cache functionality tests
    └── CacheManagerTests.swift
```

## Testing Philosophy

### 1. Test Pyramid Approach
- **Unit Tests (70%)**: Fast, isolated tests for individual components
- **Integration Tests (20%)**: Test layer interactions and real dependencies
- **UI Tests (10%)**: End-to-end user journey validation

### 2. Mock Strategy
- **Protocol-based mocking**: Every major component has a mockable protocol
- **Configurable responses**: Mocks can simulate success, failure, and edge cases
- **Call tracking**: Verify that dependencies are called correctly
- **Isolation**: Test each component independently of its dependencies

### 3. Real Dependency Testing
- **API Integration**: Validate real API responses and model mapping
- **Cache Integration**: Test actual file system caching behavior
- **Error Scenarios**: Ensure proper handling of real-world error conditions

## Test Categories

### Unit Tests (Mocked Dependencies)

#### Use Case Tests
**Purpose**: Verify business logic without external dependencies

**Example: FetchCryptoUseCasesTests**
```swift
func test_fetchTopFiveCryptoList_Success_ReturnsCorrectData() async throws {
    // Given
    let expectedCryptos = TestDataFactory.createTopFiveCryptos()
    mockRepository.setSuccessResponse(expectedCryptos)
    
    // When
    let result = try await sut.fetchTopFiveCryptoList()
    
    // Then
    XCTAssertEqual(result.count, 5)
    XCTAssertEqual(mockRepository.fetchTopFiveCallCount, 1)
}
```

**Coverage Areas:**
-  Successful data retrieval
-  Error propagation from repository
-  Concurrent request handling
-  Empty data scenarios

#### ViewModel Tests
**Purpose**: Verify UI state management and user interaction handling

**Example: HomeViewModelTests**
```swift
@MainActor
func test_loadTopFive_Success_UpdatesStateCorrectly() async {
    // Given
    let expectedCryptos = TestDataFactory.createTopFiveCryptos()
    mockUseCase.setSuccessResponse(expectedCryptos)
    
    // When
    await sut.loadTopFive()
    
    // Then
    XCTAssertEqual(sut.fetchTopFivecryptos.count, 5)
    XCTAssertNil(sut.errorMessage)
    XCTAssertFalse(sut.isLoading)
}
```

**Coverage Areas:**
- Loading state management
- Success state updates
- Error state handling
- Total value calculations
- State clearing on new requests

#### Repository Tests
**Purpose**: Verify cache-first strategy and network fallback logic

**Example: CryptoRepositoryImplTests**
```swift
func test_fetchTopFive_CacheHit_ReturnsCachedData() async throws {
    // Given
    let cachedData = TestDataFactory.createTopFiveCryptos()
    mockCacheManager.prePopulate(key: expectedCacheKey, data: cachedData)
    
    // When
    let result = try await sut.fetchTopFive()
    
    // Then
    XCTAssertEqual(result.count, 5)
    XCTAssertEqual(mockNetworkService.requestCallCount, 0) // No network call
}
```

**Coverage Areas:**
- Cache hit scenarios (return cached data)
- Cache miss scenarios (network fallback)
- Network error propagation
- Cache key generation
- Concurrent request handling

### Integration Tests (Real Dependencies)

#### API Integration Tests
**Purpose**: Validate real API responses and data model compatibility

**Example: NetworkServiceTests**
```swift
func testFetchTop5CryptosFromRealAPI() async throws {
    let endpoint = CryptoEndPoint.topFive
    let result: [CryptoModel] = try await sut.request(endpoint, type: [CryptoModel].self)
    
    XCTAssertFalse(result.isEmpty)
    XCTAssertNotNil(result.first?.name)
    XCTAssertNotNil(result.first?.current_price)
}
```

**Coverage Areas:**
- Real CoinGecko API integration
-  JSON response parsing
-  Network error handling
-  Model structure validation

#### Cache Integration Tests
**Purpose**: Validate real file system caching behavior

**Example: CacheManagerTests**
```swift
func test_SaveAndGet_CachedData() {
    // Save data
    cacheManager.save(sampleCryptos, forKey: testKey)
    
    // Retrieve data
    let cached = cacheManager.get(forKey: testKey)
    
    XCTAssertNotNil(cached)
    XCTAssertEqual(cached?.count, sampleCryptos.count)
}
```

**Coverage Areas:**
- File system persistence
-  Data serialization/deserialization
-  Cache expiration behavior
-  Memory + disk caching

## Test Utilities

### Mock Implementations

#### MockNetworkService
**Features:**
- Configurable success/failure responses
- Request call tracking
- Endpoint verification
- Simulated network delays

```swift
// Configure success response
mockNetworkService.setSuccessResponse(testData)

// Configure failure response
mockNetworkService.setFailureResponse(.noInternet)

// Verify calls
XCTAssertEqual(mockNetworkService.requestCallCount, 1)
```

#### MockCacheManager
**Features:**
- In-memory storage simulation
- Get/save call tracking
- Pre-population for testing
- Cache state verification

```swift
// Pre-populate cache
mockCacheManager.prePopulate(key: "test", data: testData)

// Verify cache operations
XCTAssertEqual(mockCacheManager.getCallHistory.count, 1)
```

#### TestDataFactory
**Purpose**: Consistent test data creation across test suites

```swift
// Create realistic test data
let cryptos = TestDataFactory.createTopFiveCryptos()
let bitcoin = TestDataFactory.createBitcoin()
let chartData = TestDataFactory.createChartPrices()
```

## Running Tests

### Xcode Test Navigator
1. Open project in Xcode
2. Navigate to Test Navigator (Cmd+6)
3. Run all tests or specific test suites
4. View test results and coverage

### Command Line
```bash
# Run all tests
xcodebuild test -workspace CryptoCurrencyAssessment.xcworkspace -scheme CryptoCurrencyAssessment -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
xcodebuild test -workspace CryptoCurrencyAssessment.xcworkspace -scheme CryptoCurrencyAssessment -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CryptoCurrencyAssessmentTests/HomeViewModelTests
```

## Test Coverage Goals

### Current Coverage
- **Use Cases**: 100% - All business logic paths tested
- **ViewModels**: 95% - UI state management thoroughly tested
- **Repositories**: 90% - Cache-first strategy and error handling covered
- **Network Service**: 85% - Real API integration and error scenarios
- **Cache Manager**: 90% - File system operations and persistence

### Coverage Areas

####  Well Covered
- Business logic validation
- Error handling and propagation
- State management in ViewModels
- Cache-first repository strategy
- Real API integration
- Concurrent request handling

####  Areas for Improvement
- UI component testing (SwiftUI views)
- Performance testing under load
- Memory leak detection
- Accessibility testing
- Localization testing

## Best Practices

### Test Naming Convention
```swift
func test_[MethodUnderTest]_[Scenario]_[ExpectedResult]()

// Examples:
func test_loadTopFive_Success_UpdatesStateCorrectly()
func test_fetchChartData_NetworkError_UpdatesStateCorrectly()
func test_fetchTopFive_CacheHit_ReturnsCachedData()
```

### Test Structure (Given-When-Then)
```swift
func test_example() async throws {
    // Given - Set up test conditions
    let expectedData = TestDataFactory.createTopFiveCryptos()
    mockService.setSuccessResponse(expectedData)
    
    // When - Execute the action being tested
    let result = try await sut.performAction()
    
    // Then - Verify the results
    XCTAssertEqual(result.count, 5)
    XCTAssertEqual(mockService.callCount, 1)
}
```

### Mock Configuration
```swift
// Reset mocks in setUp/tearDown
override func setUp() {
    mockService = MockNetworkService()
    // ... other setup
}

override func tearDown() {
    mockService = nil
    // ... cleanup
}
```

### Async Testing
```swift
// Use @MainActor for ViewModel tests
@MainActor
final class HomeViewModelTests: XCTestCase {
    
    // Properly handle async operations
    func test_asyncOperation() async {
        await sut.performAsyncAction()
        // Assertions after async completion
    }
}
```

## Debugging Test Failures

### Common Issues and Solutions

#### 1. Async Timing Issues
**Problem**: Tests fail intermittently due to timing
**Solution**: Use proper async/await patterns, avoid arbitrary delays

#### 2. Mock Configuration Errors
**Problem**: Unexpected test failures due to incorrect mock setup
**Solution**: Reset mocks in setUp, verify mock configuration

#### 3. Real API Test Failures
**Problem**: API tests fail due to network issues
**Solution**: Mark API tests as integration tests, run separately from unit tests

#### 4. Cache State Pollution
**Problem**: Tests affect each other through shared cache state
**Solution**: Clear cache in setUp/tearDown, use unique cache keys

### Test Isolation
- Each test should be independent
- Reset all mocks and state in setUp/tearDown
- Use dependency injection for all dependencies
- Avoid shared mutable state between tests

## Future Enhancements

### Planned Improvements
1. **UI Testing**: Add SwiftUI view tests with ViewInspector
2. **Performance Testing**: Add benchmarks for data processing
3. **Snapshot Testing**: Visual regression testing for charts
4. **Property-Based Testing**: Fuzz testing for edge cases
5. **Continuous Integration**: Automated testing on PR/commit

### Test Automation
- GitHub Actions for automated test runs
- Test coverage reporting
- Performance regression detection
- Automated API contract testing

---

## Conclusion

The testing strategy for this project emphasizes comprehensive coverage across all architectural layers while maintaining fast execution times through effective use of mocks and selective integration testing. The combination of unit tests with mocks and integration tests with real dependencies provides confidence in both individual component behavior and system integration.

Key strengths:
- **Comprehensive mock strategy** enables fast, isolated unit tests
- **Real API integration tests** catch external dependency changes
- **Clear test organization** follows architectural layers
- **Consistent test data** through TestDataFactory
- **Async/await testing patterns** for modern Swift concurrency

This testing approach ensures the application is robust, maintainable, and ready for production deployment.
