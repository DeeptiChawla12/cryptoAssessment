
//
//  Architecture.md
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 12/11/25.
//


# CryptoCurrency Assessment - Technical Architecture Documentation

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Layer Responsibilities](#layer-responsibilities)
- [Design Patterns](#design-patterns)
- [Data Flow](#data-flow)
- [Error Handling Strategy](#error-handling-strategy)
- [Testing Strategy](#testing-strategy)
- [Performance Considerations](#performance-considerations)
- [API Integration](#api-integration)
- [Caching Strategy](#caching-strategy)

## Architecture Overview

This iOS application follows **Clean Architecture** principles with **MVVM** pattern for the presentation layer, ensuring:

- **Separation of Concerns**: Each layer has distinct responsibilities
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Testability**: Each layer can be tested in isolation
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features or modify existing ones

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │   SwiftUI   │    │ ViewModels  │    │   Views     │  │
│  │   Views     │◄──►│(@Published) │◄──►│ Components  │  │
│  └─────────────┘    └─────────────┘    └─────────────┘  │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                   Domain Layer                          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │   Entities  │    │  Use Cases  │    │ Repository  │  │
│  │(CryptoModel)│    │(Protocols)  │    │ Protocols   │  │
│  └─────────────┘    └─────────────┘    └─────────────┘  │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │ Repository  │    │   Network   │    │    Cache    │  │
│  │    Impl     │◄──►│   Service   │    │  Manager    │  │
│  └─────────────┘    └─────────────┘    └─────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### Presentation Layer
- **SwiftUI Views**: User interface components, navigation, user interaction
- **ViewModels**: UI state management, data binding, user action handling
- **View Components**: Reusable UI elements (CryptoRowView, ChartView, etc.)

**Key Files:**
- `HomeView.swift` - Main cryptocurrency list screen
- `CryptoDetailView.swift` - Detailed view with charts
- `HomeViewModel.swift` - Manages list state and total calculations
- `CryptoDetailViewModel.swift` - Handles chart data and detail state

### Domain Layer
- **Entities**: Core business models (CryptoModel, ChartResponse)
- **Use Cases**: Business logic operations (fetch crypto data, fetch charts)
- **Repository Protocols**: Data access contracts

**Key Files:**
- `CryptoModel.swift` - Main cryptocurrency data model
- `FetchCryptoUseCases.swift` - Business logic for fetching top 5 cryptos
- `FetchChartUseCase.swift` - Business logic for chart data
- `CryptoRepositoryProtocol.swift` - Data access contract

### Data Layer
- **Repository Implementations**: Concrete data access with cache-first strategy
- **Network Service**: HTTP client with async/await support
- **Cache Manager**: File-based caching with expiration

**Key Files:**
- `CryptoRepositoryImpl.swift` - Implements cache-first data fetching
- `NetworkService.swift` - HTTP client with comprehensive error handling
- `CacheManager.swift` - File-based caching with 24-hour expiry

## Design Patterns

### 1. Clean Architecture
**Purpose**: Separation of concerns and dependency inversion

**Implementation:**
- Outer layers depend on inner layers, never the reverse
- Domain layer is framework-independent
- Business logic isolated in use cases

### 2. MVVM (Model-View-ViewModel)
**Purpose**: Reactive UI with clear separation between view logic and business logic

**Implementation:**
```swift
// ViewModel manages state and exposes it to views
@Published var fetchTopFivecryptos: [CryptoModel] = []
@Published var isLoading = false
@Published var errorMessage: String?

// Views observe state changes
@StateObject private var homeViewModel: HomeViewModel
```

### 3. Repository Pattern
**Purpose**: Abstract data access and provide cache-first strategy

**Implementation:**
```swift
func fetchTopFive() async throws -> [CryptoModel] {
    // 1. Check cache first
    if let cached = cacheManager.get(forKey: cacheKey) {
        return cached
    }
    
    // 2. Fallback to network
    let data = try await networkService.request(endpoint, type: [CryptoModel].self)
    
    // 3. Save to cache
    cacheManager.save(data, forKey: cacheKey)
    return data
}
```

### 4. Dependency Injection
**Purpose**: Loose coupling and testability

**Implementation:**
- Constructor injection throughout all layers
- Protocol-based dependencies
- Easy to mock for testing

### 5. Protocol-Oriented Programming
**Purpose**: Contract-based design and testability

**Implementation:**
- Every major component has a protocol
- Enables easy mocking and testing
- Clear contracts between layers

## Data Flow

### 1. User Interaction → ViewModel
```swift
// User opens app → View calls ViewModel
.task {
    await homeViewModel.loadTopFive()
}
```

### 2. ViewModel → Use Case
```swift
// ViewModel delegates to Use Case
@MainActor
func loadTopFive() async {
    isLoading = true
    do {
        fetchTopFivecryptos = try await fetchCryptoUseCase.fetchTopFiveCryptoList()
    } catch {
        errorMessage = error.localizedDescription
    }
    isLoading = false
}
```

### 3. Use Case → Repository
```swift
// Use Case calls Repository
func fetchTopFiveCryptoList() async throws -> [CryptoModel] {
    try await cryptoRepository.fetchTopFive()
}
```

### 4. Repository → Cache/Network
```swift
// Repository implements cache-first strategy
func fetchTopFive() async throws -> [CryptoModel] {
    // Cache first, network fallback, then cache result
}
```

### 5. Data → UI Updates
```swift
// @Published properties trigger UI updates automatically
@Published var fetchTopFivecryptos: [CryptoModel] = []
```

## Error Handling Strategy

### Centralized Error Types
```swift
enum NetworkError: Error, LocalizedError {
    case badURL
    case invalidResponse(statusCode: Int)
    case decodingError
    case noInternet
    case timeout
    case noData
    case unknown(Error)
}
```

### Error Propagation Chain
1. **Network Layer**: Catches URLSession errors, converts to NetworkError
2. **Repository Layer**: Propagates NetworkError unchanged
3. **Use Case Layer**: Propagates errors unchanged
4. **ViewModel Layer**: Converts errors to user-friendly messages
5. **View Layer**: Displays error messages to user

### User Experience
- Loading states during network operations
- Clear error messages for different scenarios
- Graceful degradation (cached data when network fails)

## Testing Strategy

### Test Structure
```
Tests/
├── Mocks/                 # Mock implementations
├── UseCaseTests/         # Domain layer tests
├── ViewModelTests/       # Presentation layer tests  
├── RepositoryTests/      # Data layer integration tests
├── APIUnitTest/          # Real API integration tests
└── CacheUnitTest/        # Cache functionality tests
```

### Testing Approaches

#### 1. Unit Tests with Mocks
- **Purpose**: Test individual components in isolation
- **Scope**: Use cases, ViewModels, Repository logic
- **Mocks**: NetworkService, CacheManager, Repositories

#### 2. Integration Tests
- **Purpose**: Test layer interactions
- **Scope**: Repository + Network + Cache integration
- **Real Dependencies**: Actual Cache library, controlled network responses

#### 3. API Tests
- **Purpose**: Validate API integration
- **Scope**: Real API calls with live endpoints
- **Benefits**: Catch API changes, validate data models

### Mock Strategy
- Comprehensive mocks for all protocols
- Configurable success/failure responses
- Call tracking for verification
- Test data factory for consistent test data

## Performance Considerations

### Caching Strategy
- **24-hour cache expiry** balances data freshness with performance
- **Memory + Disk caching** for multi-level performance
- **Cache-first strategy** minimizes network requests

### Async/Await Benefits
- **Non-blocking UI** during network operations
- **Structured concurrency** prevents callback hell
- **Automatic error propagation** simplifies error handling

### Memory Management
- **Weak references** in closures prevent retain cycles
- **@Published properties** use efficient observation
- **Lazy loading** for chart data (only when detail view opens)

## API Integration

### CoinGecko API
- **Base URL**: `https://api.coingecko.com`
- **Authentication**: API key in query parameters
- **Currency**: AUD (Australian Dollars)
- **Rate Limiting**: Handled by cache-first strategy

### Endpoints
1. **Top 5 Cryptocurrencies**: `/api/v3/coins/markets`
2. **Market Charts**: `/api/v3/coins/{id}/market_chart`

### Request Flow
1. Build endpoint with query parameters
2. Create URLRequest with timeout (15 seconds)
3. Perform request with URLSession.shared.data()
4. Validate HTTP status code (200-299)
5. Decode JSON to model objects

## Caching Strategy

### Technology
- **HugeJavascript Cache Pod**: Provides disk + memory caching
- **24-hour expiry**: Balances freshness with performance
- **Codable integration**: Automatic serialization/deserialization

### Cache Keys
- Derived from URL relative paths
- Consistent across app sessions
- Unique per endpoint

### Cache Flow
1. **Check cache** using URL-based key
2. **Return cached data** if available and not expired
3. **Fetch from network** if cache miss
4. **Save network response** to cache
5. **Return data** to caller

### Benefits
- **Reduced network usage**: Fewer API calls
- **Improved performance**: Faster data loading
- **Offline capability**: Works without internet (with cached data)
- **Battery efficiency**: Less network radio usage

---

## Development Guidelines

### Adding New Features
1. **Start with Domain**: Create entities and use cases
2. **Implement Data**: Add repository and network integration
3. **Build Presentation**: Create views and view models
4. **Add Tests**: Unit tests for all layers
5. **Update Documentation**: Keep this file current

### Code Standards
- **Protocol-first**: Define interfaces before implementations
- **Async/await**: Use modern concurrency patterns
- **Error handling**: Always handle and propagate errors appropriately
- **Testing**: Every component should have corresponding tests
- **Documentation**: Comments for public interfaces and complex logic
