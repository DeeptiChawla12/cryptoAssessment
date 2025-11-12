# API Integration Guide - CryptoCurrency Assessment

## Overview

This document provides detailed information about the CoinGecko API integration used in the CryptoCurrency Assessment app, including endpoint specifications, data models, error handling, and best practices.

## CoinGecko API Integration

### Base Configuration
- **Base URL**: `https://api.coingecko.com`
- **API Version**: v3
- **Authentication**: API Key (query parameter)
- **Default Currency**: AUD (Australian Dollars)
- **Timeout**: 15 seconds per request
- **Rate Limiting**: Handled via 24-hour caching strategy

### API Key Management
```swift
// Stored in AppConstants for centralized configuration
enum AppConstants {
    enum API {
        static let baseURL = "https://api.coingecko.com"
        static let apiKey = "CG-LXENXysWegGc4BWgoLfzWNL4"
        static let currency = "aud"
    }
}
```

## Endpoints

### 1. Top 5 Cryptocurrencies

#### Endpoint Details
- **Path**: `/api/v3/coins/markets`
- **Method**: GET
- **Purpose**: Fetch the top 5 cryptocurrencies by market cap

#### Query Parameters
```swift
[
    URLQueryItem(name: "api_key", value: AppConstants.API.apiKey),
    URLQueryItem(name: "vs_currency", value: AppConstants.API.currency),
    URLQueryItem(name: "per_page", value: AppConstants.API.topFiveCount),
    URLQueryItem(name: "page", value: "1")
]
```

#### Full URL Example
```
https://api.coingecko.com/api/v3/coins/markets?api_key=CG-LXENXysWegGc4BWgoLfzWNL4&vs_currency=aud&per_page=5&page=1
```

#### Response Model
```swift
struct CryptoModel: Codable, Identifiable {
    var id: String?                              // "bitcoin"
    var symbol: String?                          // "btc"
    var name: String?                            // "Bitcoin"
    var image: String?                           // Icon URL
    var current_price: Double?                   // 65000.0 (in AUD)
    var market_cap: Double?                      // Market capitalization
    var market_cap_rank: Double?                 // 1.0 (ranking position)
    var total_volume: Double?                    // 24h trading volume
    var high_24h: Double?                        // 24h high price
    var low_24h: Double?                         // 24h low price
    var price_change_24h: Double?                // Absolute price change
    var price_change_percentage_24h: Double?     // Percentage price change
    var ath: Double?                             // All-time high
    var ath_change_percentage: Double?           // % change from ATH
    var ath_date: String?                        // ATH date (ISO format)
    var last_updated: String?                    // Last update timestamp
    // ... additional fields
}
```

#### Sample Response
```json
[
  {
    "id": "bitcoin",
    "symbol": "btc",
    "name": "Bitcoin",
    "image": "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
    "current_price": 65000.50,
    "market_cap": 1200000000000,
    "market_cap_rank": 1,
    "price_change_24h": 1500.25,
    "price_change_percentage_24h": 2.36,
    "ath": 73500.0,
    "ath_change_percentage": -11.56,
    "ath_date": "2021-11-10T14:24:11.849Z"
  }
]
```

### 2. Market Chart Data

#### Endpoint Details
- **Path**: `/api/v3/coins/{id}/market_chart`
- **Method**: GET
- **Purpose**: Fetch historical price data for chart visualization

#### Path Parameters
- **{id}**: Cryptocurrency identifier (e.g., "bitcoin", "ethereum")

#### Query Parameters
```swift
[
    URLQueryItem(name: "api_key", value: AppConstants.API.apiKey),
    URLQueryItem(name: "vs_currency", value: AppConstants.API.currency),
    URLQueryItem(name: "days", value: "\(days)") // Default: 7 days
]
```

#### Full URL Example
```
https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?api_key=CG-LXENXysWegGc4BWgoLfzWNL4&vs_currency=aud&days=7
```

#### Response Model
```swift
struct ChartResponse: Codable {
    let prices: [[Double]]  // Array of [timestamp, price] pairs
}

// Example prices array:
// [
//   [1699833600000.0, 65000.0],  // [Unix timestamp, Price in AUD]
//   [1699920000000.0, 65200.0],
//   [1700006400000.0, 64800.0]
// ]
```

#### Data Processing
```swift
// Extract price values from timestamp-price pairs
func fetchChart(for id: String) async throws -> [Double] {
    let endpoint = CryptoEndPoint.marketChart(id: id, days: 7)
    let response = try await networkService.request(endpoint, type: ChartResponse.self)
    return response.prices.map { $0[1] } // Extract price (index 1) from each pair
}
```

## Network Service Implementation

### Core Network Service
```swift
final class NetworkService: NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: EndPoint, type: T.Type) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 15
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: -1)
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
```

### Endpoint Configuration
```swift
enum CryptoEndPoint: EndPoint {
    case topFive
    case marketChart(id: String, days: Int)
    
    var baseURL: String {
        AppConstants.API.baseURL
    }
    
    var path: String {
        switch self {
        case .topFive:
            return AppConstants.API.cryptoMarketsPath // "/api/v3/coins/markets"
        case .marketChart(let id, _):
            return "/api/v3/coins/\(id)/market_chart"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        var items = [
            URLQueryItem(name: AppConstants.QueryKeys.apiKey, value: AppConstants.API.apiKey),
            URLQueryItem(name: AppConstants.QueryKeys.vsCurrency, value: AppConstants.API.currency)
        ]
        
        switch self {
        case .topFive:
            items.append(contentsOf: [
                URLQueryItem(name: AppConstants.QueryKeys.perPage, value: AppConstants.API.topFiveCount),
                URLQueryItem(name: AppConstants.QueryKeys.page, value: "1")
            ])
        case .marketChart(_, let days):
            items.append(URLQueryItem(name: "days", value: "\(days)"))
        }
        
        return items
    }
    
    var method: HTTPMethod {
        .GET
    }
}
```

## Error Handling

### Network Error Types
```swift
enum NetworkError: Error, LocalizedError {
    case badURL                           // Invalid endpoint URL
    case invalidResponse(statusCode: Int) // HTTP error status codes
    case decodingError                   // JSON parsing failure
    case noInternet                      // Network connectivity issues
    case timeout                         // Request timeout (15 seconds)
    case noData                          // Empty response body
    case unknown(Error)                  // Unexpected errors
}
```

### Error Mapping
| HTTP Status | NetworkError | User Message |
|------------|--------------|--------------|
| 400 | invalidResponse(400) | "Bad Request. Please try again later." |
| 401 | invalidResponse(401) | "Unauthorized. Please check API key." |
| 403 | invalidResponse(403) | "Forbidden. Access denied." |
| 404 | invalidResponse(404) | "Resource not found. Please try again later." |
| 429 | invalidResponse(429) | "Too many requests. Please wait and try again." |
| 500+ | invalidResponse(5xx) | "Server error. Please try again later." |
| No Network | noInternet | "No internet connection. Please check your network." |
| Timeout | timeout | "Request timed out. Please try again." |

### Error Handling Flow
```swift
// Repository level - propagates NetworkError
func fetchTopFive() async throws -> [CryptoModel] {
    // Cache check first...
    
    do {
        let data = try await networkService.request(endpoint, type: [CryptoModel].self)
        // Cache and return data...
        return data
    } catch {
        throw error // Propagate NetworkError unchanged
    }
}

// ViewModel level - converts to user-friendly messages
@MainActor
func loadTopFive() async {
    do {
        fetchTopFivecryptos = try await fetchCryptoUseCase.fetchTopFiveCryptoList()
    } catch let error as NetworkError {
        errorMessage = error.localizedDescription
    } catch {
        errorMessage = "Unexpected error: \(error.localizedDescription)"
    }
}
```

## Caching Strategy

### Cache-First Approach
1. **Check Cache**: Look for cached data using URL-based key
2. **Return Cached**: If found and not expired, return immediately
3. **Network Fallback**: If cache miss, fetch from API
4. **Cache Response**: Save network response for future use
5. **Return Data**: Provide data to caller

### Cache Implementation
```swift
func fetchTopFive() async throws -> [CryptoModel] {
    guard let url = CryptoEndPoint.topFive.url else {
        throw URLError(.badURL)
    }
    
    let cacheKey = url.relativePath
    
    // 1. Try cache first
    if let cached = cacheManager.get(forKey: cacheKey) {
        return cached
    }
    
    // 2. Fallback to network
    let data = try await networkService.request(CryptoEndPoint.topFive, type: [CryptoModel].self)
    
    // 3. Cache the response
    cacheManager.save(data, forKey: cacheKey)
    
    return data
}
```

### Cache Configuration
- **Library**: HugeJavascript Cache pod
- **Expiry**: 24 hours (`Expiry.seconds(24 * 60 * 60)`)
- **Storage**: Memory + Disk persistence
- **Key Format**: URL relative path (e.g., "/api/v3/coins/markets")

## Performance Optimizations

### Request Optimization
- **Timeout**: 15-second timeout prevents hanging requests
- **Concurrent Requests**: Async/await enables concurrent API calls
- **Minimal Data**: Request only required fields to reduce payload size

### Caching Benefits
- **Reduced API Calls**: 24-hour cache reduces API usage by ~96%
- **Faster Loading**: Cached responses are instant
- **Offline Capability**: App works with cached data when offline
- **Battery Efficiency**: Less network usage saves battery

### Rate Limiting Mitigation
- **Cache Strategy**: Reduces API calls below rate limits
- **Error Handling**: Graceful handling of 429 (Too Many Requests) errors
- **Exponential Backoff**: Could be added for retry logic

## Testing API Integration

### Real API Tests
```swift
func testFetchTop5CryptosFromRealAPI() async throws {
    let endpoint = CryptoEndPoint.topFive
    let result: [CryptoModel] = try await sut.request(endpoint, type: [CryptoModel].self)
    
    XCTAssertFalse(result.isEmpty, "Expected non-empty list")
    XCTAssertNotNil(result.first?.name, "Expected valid crypto name")
    XCTAssertNotNil(result.first?.current_price, "Expected valid price")
}
```

### Mock API Tests
```swift
func test_fetchTopFive_Success_ReturnsCorrectData() async throws {
    let mockData = TestDataFactory.createTopFiveCryptos()
    mockNetworkService.setSuccessResponse(mockData)
    
    let result = try await sut.fetchTopFive()
    
    XCTAssertEqual(result.count, 5)
    XCTAssertEqual(mockNetworkService.requestCallCount, 1)
}
```

## API Best Practices

### Request Guidelines
1. **Always include API key** in query parameters
2. **Specify currency** (AUD) for consistent pricing
3. **Use appropriate timeouts** (15 seconds)
4. **Handle all HTTP status codes** gracefully
5. **Validate response data** before processing

### Error Handling Guidelines
1. **Distinguish error types** (network vs parsing vs business logic)
2. **Provide user-friendly messages** for all error scenarios
3. **Log detailed errors** for debugging while showing simple messages to users
4. **Implement retry logic** for transient errors (optional future enhancement)

### Security Considerations
1. **API Key Protection**: Store securely, avoid logging
2. **HTTPS Only**: All API calls use HTTPS
3. **Input Validation**: Validate cryptocurrency IDs before API calls
4. **Rate Limiting Respect**: Use caching to stay within API limits

## Future Enhancements

### Potential API Improvements
1. **Retry Logic**: Implement exponential backoff for transient errors
2. **Request Cancellation**: Cancel ongoing requests when view disappears
3. **Batch Requests**: Combine multiple API calls where possible
4. **Real-time Updates**: WebSocket integration for live price updates
5. **Additional Endpoints**: Market data, news, exchange rates

### Monitoring and Analytics
1. **API Success Rates**: Track request success/failure rates
2. **Response Times**: Monitor API performance
3. **Cache Hit Rates**: Measure caching effectiveness
4. **Error Frequency**: Track common error scenarios

---

## Conclusion

The CoinGecko API integration provides reliable cryptocurrency data through a well-structured network layer with comprehensive error handling and efficient caching. The cache-first strategy significantly improves performance while reducing API usage, making the app responsive and efficient.

Key strengths:
- **Robust error handling** for all scenarios
- **Efficient caching strategy** reduces API calls by 96%
- **Clean async/await implementation** for modern Swift concurrency
- **Comprehensive testing** with both real and mocked API calls
- **Flexible endpoint configuration** for easy maintenance and extension

This API integration design provides a solid foundation for a production cryptocurrency application with room for future enhancements and scaling.
