//
//  Development.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 12/11/25.
//

# Development Guide - CryptoCurrency Assessment

## Quick Start

### Prerequisites
- **macOS**: 12.0+ (Monterey or later)
- **Xcode**: 15.0+
- **iOS SDK**: 16.0+ target deployment
- **CocoaPods**: Latest version for dependency management
- **Git**: For version control

### Setup Instructions

1. **Clone Repository**
```bash
git clone https://github.com/DeeptiChawla12/cryptoAssessment.git
cd cryptoAssessment
```

2. **Install Dependencies**
```bash
# Install CocoaPods if not already installed
sudo gem install cocoapods

# Install project dependencies
pod install
```

3. **Open Project**
```bash
# IMPORTANT: Always open .xcworkspace, not .xcodeproj
open CryptoCurrencyAssessment.xcworkspace
```

4. **Build and Run**
- Select target device/simulator (iPhone 15 recommended)
- Press `Cmd+R` to build and run
- For tests: Press `Cmd+U`

## Project Structure

### Directory Organization
```
CryptoCurrencyAssessment/
├── CryptoCurrencyAssessmentApp.swift    # App entry point
├── Common/
│   └── Resources/
│       └── AppConstants.swift           # App-wide constants
├── Data/                                # Data layer
│   ├── Cache/
│   │   ├── CacheManager.swift          # File-based caching
│   │   └── ImageCacheManager.swift     # Image caching
│   ├── Network/
│   │   ├── NetworkService.swift        # HTTP client
│   │   ├── CryptoEndPoint.swift        # API endpoints
│   │   ├── NetworkError.swift          # Error definitions
│   │   ├── EndPoint.swift              # Protocol definitions
│   │   └── HTTPMethod.swift            # HTTP methods
│   └── RepositoryImpl/
│       ├── CryptoRepositoryImpl.swift  # Main crypto repository
│       └── DetailCryptoRepositoryImpl.swift # Chart repository
├── Domain/                              # Domain layer
│   ├── Entity/
│   │   ├── CryptoModel.swift           # Core data models
│   │   └── ChartResponse.swift         # Chart data model
│   ├── Repository/
│   │   ├── CryptoRepositoryProtocol.swift      # Data contracts
│   │   └── DetailCryptoRepositoryProtocol.swift
│   └── UseCases/
│       ├── FetchCryptoUseCases.swift   # Business logic
│       └── FetchChartUseCaseProtocol.swift
└── Presentation/                        # Presentation layer
    ├── HomePage/
    │   ├── View/
    │   │   ├── HomeView.swift          # Main screen
    │   │   ├── CryptoRowView.swift     # List item component
    │   │   ├── ButtonView.swift        # Reusable button
    │   │   └── CachedAsyncImage.swift  # Image loader
    │   └── ViewModel/
    │       └── HomeViewModel.swift     # Home screen state
    └── DetailPage/
        ├── View/
        │   ├── CryptoDetailView.swift  # Detail screen
        │   ├── CryptoChartView.swift   # Chart component
        │   ├── PriceHeaderView.swift   # Price display
        │   ├── DurationTabView.swift   # Time period selector
        │   ├── ActionButtonsView.swift # Action buttons
        │   ├── AccountValueCard.swift  # Account info card
        │   └── LatestActivitiesView.swift # Activity list
        └── ViewModel/
            └── CryptoDetailViewModel.swift # Detail state
```

### Key Files by Layer

#### Data Layer
- **CacheManager.swift**: 24-hour file-based caching with Cache pod
- **NetworkService.swift**: Async/await HTTP client with comprehensive error handling
- **CryptoRepositoryImpl.swift**: Cache-first data access strategy

#### Domain Layer
- **CryptoModel.swift**: Core cryptocurrency data model matching CoinGecko API
- **FetchCryptoUseCases.swift**: Business logic for fetching top 5 cryptocurrencies
- **Repository Protocols**: Contracts for data access layers

#### Presentation Layer
- **HomeView.swift**: Main list screen with dependency injection setup
- **CryptoDetailView.swift**: Detail view with charts and comprehensive crypto info
- **ViewModels**: ObservableObject classes managing UI state with @Published properties

## Architectural Patterns

### Clean Architecture Implementation

#### Dependency Flow
```
Presentation → Domain → Data
     ↓           ↓        ↓
   Views    Use Cases  Repositories
     ↓           ↓        ↓
ViewModels   Protocols  Network/Cache
```

#### Dependency Injection
```swift
// Example from HomeView.swift
init() {
    let network = NetworkService()
    let repository = CryptoRepositoryImpl(networkService: network)
    let useCase = FetchCryptopFiveUseCases(cryptoRepository: repository)
    _homeViewModel = StateObject(wrappedValue: HomeViewModel(fetchCryptoUseCase: useCase))
}
```

### MVVM Pattern
- **Views**: SwiftUI declarative UI, minimal logic
- **ViewModels**: ObservableObject with @Published properties
- **Models**: Codable structs for data representation

### Repository Pattern
```swift
// Cache-first strategy in every repository
func fetchData() async throws -> [DataModel] {
    // 1. Check cache
    if let cached = cacheManager.get(forKey: cacheKey) {
        return cached
    }
    
    // 2. Network fallback
    let networkData = try await networkService.request(endpoint, type: [DataModel].self)
    
    // 3. Cache result
    cacheManager.save(networkData, forKey: cacheKey)
    
    return networkData
}
```

## Development Workflows

### Adding New Features

#### 1. Domain-First Approach
Start with the domain layer to define business logic:

```swift
// 1. Define entity (if needed)
struct NewDataModel: Codable, Identifiable {
    let id: String
    let name: String
    // ... other properties
}

// 2. Create repository protocol
protocol NewDataRepositoryProtocol {
    func fetchNewData() async throws -> [NewDataModel]
}

// 3. Create use case
protocol FetchNewDataUseCaseProtocol {
    func execute() async throws -> [NewDataModel]
}

class FetchNewDataUseCase: FetchNewDataUseCaseProtocol {
    private let repository: NewDataRepositoryProtocol
    
    init(repository: NewDataRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [NewDataModel] {
        try await repository.fetchNewData()
    }
}
```

#### 2. Data Layer Implementation
```swift
// 1. Add endpoint to CryptoEndPoint enum
enum CryptoEndPoint: EndPoint {
    case topFive
    case marketChart(id: String, days: Int)
    case newEndpoint // Add new case
    
    var path: String {
        switch self {
        // ... existing cases
        case .newEndpoint:
            return "/api/v3/new/endpoint"
        }
    }
}

// 2. Implement repository
class NewDataRepositoryImpl: NewDataRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheManager: CacheManagerProtocol
    
    func fetchNewData() async throws -> [NewDataModel] {
        // Implement cache-first strategy
    }
}
```

#### 3. Presentation Layer
```swift
// 1. Create ViewModel
class NewDataViewModel: ObservableObject {
    @Published var data: [NewDataModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let useCase: FetchNewDataUseCaseProtocol
    
    init(useCase: FetchNewDataUseCaseProtocol) {
        self.useCase = useCase
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            data = try await useCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// 2. Create SwiftUI View
struct NewDataView: View {
    @StateObject private var viewModel: NewDataViewModel
    
    init() {
        // Dependency injection setup
        let network = NetworkService()
        let repository = NewDataRepositoryImpl(networkService: network)
        let useCase = FetchNewDataUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: NewDataViewModel(useCase: useCase))
    }
    
    var body: some View {
        // SwiftUI implementation
    }
}
```

### Testing New Features

#### 1. Unit Tests
```swift
// Test use case
final class FetchNewDataUseCaseTests: XCTestCase {
    var sut: FetchNewDataUseCase!
    var mockRepository: MockNewDataRepository!
    
    override func setUp() {
        mockRepository = MockNewDataRepository()
        sut = FetchNewDataUseCase(repository: mockRepository)
    }
    
    func test_execute_success() async throws {
        // Given
        let expectedData = [NewDataModel(id: "test", name: "Test")]
        mockRepository.setSuccessResponse(expectedData)
        
        // When
        let result = try await sut.execute()
        
        // Then
        XCTAssertEqual(result, expectedData)
    }
}

// Test ViewModel
@MainActor
final class NewDataViewModelTests: XCTestCase {
    // Similar testing pattern
}
```

### Code Quality Standards

#### Naming Conventions
- **Classes**: PascalCase (`CryptoRepository`)
- **Functions/Variables**: camelCase (`fetchTopFive`)
- **Constants**: camelCase (`apiKey`)
- **Enums**: PascalCase with camelCase cases
- **Protocols**: PascalCase with "Protocol" suffix

#### File Organization
- One public class/struct per file
- File name matches the main type name
- Group related functionality in MARK sections
- Organize imports alphabetically

#### Documentation Standards
```swift
/// Brief description of the class/struct/enum
///
/// Detailed explanation of purpose and usage patterns.
/// Include important implementation details.
///
/// - Important: Any critical usage notes
/// - Warning: Potential pitfalls or limitations
class ExampleClass {
    
    /// Brief description of the method
    ///
    /// Detailed explanation of what the method does,
    /// including any side effects or important behavior.
    ///
    /// - Parameter param: Description of the parameter
    /// - Returns: Description of return value
    /// - Throws: Description of possible errors
    func exampleMethod(param: String) async throws -> String {
        // Implementation
    }
}
```

## Common Development Tasks

### Running Tests
```bash
# All tests
xcodebuild test -workspace CryptoCurrencyAssessment.xcworkspace -scheme CryptoCurrencyAssessment -destination 'platform=iOS Simulator,name=iPhone 15'

# Specific test class
xcodebuild test -workspace CryptoCurrencyAssessment.xcworkspace -scheme CryptoCurrencyAssessment -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CryptoCurrencyAssessmentTests/HomeViewModelTests

# Unit tests only (excluding integration tests)
xcodebuild test -workspace CryptoCurrencyAssessment.xcworkspace -scheme CryptoCurrencyAssessment -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CryptoCurrencyAssessmentTests/UseCaseTests
```

### Debugging Network Issues
```swift
// Add breakpoints in NetworkService.swift
func request<T: Decodable>(_ endpoint: EndPoint, type: T.Type) async throws -> T {
    // Breakpoint here to inspect endpoint URL
    guard let url = endpoint.url else {
        throw NetworkError.badURL
    }
    
    // Breakpoint here to inspect request
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // Breakpoint here to inspect response
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.invalidResponse(statusCode: -1)
    }
}
```

### Cache Debugging
```swift
// Add print statements in CacheManager.swift
func get(forKey key: String) -> [CryptoModel]? {
    let result = try? storage.object(forKey: key)
    print("Cache GET - Key: \(key), Found: \(result != nil)")
    return result
}

func save(_ data: [CryptoModel], forKey key: String) {
    try? storage.setObject(data, forKey: key, expiry: expiry)
    print("Cache SAVE - Key: \(key), Count: \(data.count)")
}
```

### Performance Profiling
1. **Instruments**: Use Xcode Instruments for memory and CPU profiling
2. **Network Debugging**: Use Charles Proxy or Xcode Network debugging
3. **View Debugging**: Use Xcode View Debugger for UI issues

## Build Configuration

### Debug vs Release
- **Debug**: Full logging, no optimization, debug symbols included
- **Release**: Optimized code, minimal logging, stripped debug symbols

### Scheme Configuration
- **CryptoCurrencyAssessment**: Main app target
- **CryptoCurrencyAssessmentTests**: Unit and integration tests
- **CryptoCurrencyAssessmentUITests**: UI automation tests

## Dependencies Management

### CocoaPods Configuration
```ruby
# Podfile
target 'CryptoCurrencyAssessment' do
  use_frameworks!
  pod 'Cache'  # HugeJavascript caching library
end
```

### Updating Dependencies
```bash
# Update all pods to latest versions
pod update

# Update specific pod
pod update Cache

# Install new pods after Podfile changes
pod install
```

### Adding New Dependencies
1. Edit `Podfile`
2. Run `pod install`
3. Import in relevant Swift files
4. Update documentation

## Performance Considerations

### Memory Management
- Use `weak` references in closures to prevent retain cycles
- Leverage `@Published` properties for efficient UI updates
- Dispose of large objects when no longer needed

### Network Optimization
- 24-hour caching reduces API calls by ~96%
- 15-second timeout prevents hanging requests
- Async/await enables concurrent operations

### UI Performance
- SwiftUI's declarative nature handles most optimizations
- Use `@StateObject` for view model lifecycle management
- Lazy loading for chart data (only when detail view opens)

## Troubleshooting

### Common Issues

#### 1. Build Errors
**Problem**: "Could not find module 'Cache'"
**Solution**: Ensure you opened `.xcworkspace` not `.xcodeproj`

#### 2. Network Errors
**Problem**: API requests failing
**Solution**: Check internet connection, verify API key, check endpoint URLs

#### 3. Cache Issues
**Problem**: Data not persisting between app launches
**Solution**: Verify cache directory permissions, check expiry settings

#### 4. UI Not Updating
**Problem**: SwiftUI views not reflecting data changes
**Solution**: Ensure `@Published` properties are used, check `@MainActor` usage

### Debug Checklist
1.  Using `.xcworkspace` file
2.  All pods installed correctly
3.  Valid API key in AppConstants
4.  Network connection available
5.  Proper dependency injection setup
6.  @MainActor for UI updates

## Future Development

### Planned Enhancements
1. **Pull-to-Refresh**: Add refresh capability to main list
2. **Search Functionality**: Search for specific cryptocurrencies
3. **Portfolio Tracking**: Add personal portfolio management
4. **Price Alerts**: Notification system for price changes
5. **Additional Charts**: More chart types and time periods

### Architecture Improvements
1. **Coordinators**: Add navigation coordination pattern
2. **Modularization**: Split into feature-based modules
3. **Configuration Management**: Environment-based configuration
4. **Logging Framework**: Structured logging system

---

## Conclusion

This development guide provides comprehensive information for working with the CryptoCurrency Assessment project. The architecture is designed for maintainability, testability, and scalability, following modern iOS development best practices.

Key development principles:
- **Clean Architecture**: Clear separation of concerns
- **Dependency Injection**: Loose coupling between components
- **Protocol-Oriented**: Contract-based design
- **Testing**: Comprehensive test coverage
- **Documentation**: Clear code documentation and guides

The project structure and patterns make it easy to add new features, modify existing functionality, and maintain code quality as the application grows.
