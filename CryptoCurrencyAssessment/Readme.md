# 🪙 CryptoCurrency Assessment (iOS)

An iOS application that fetches the **Top 5 cryptocurrencies** from the [CoinGecko](https://www.coingecko.com/) public API and displays real-time prices and details for each coin.

This project demonstrates **Clean Architecture**, **MVVM**, **Swift Concurrency (async/await)**, **24-hour caching**, and **unit testing** — all built with **SwiftUI**.

---

## 🧩 Architecture Overview

The project is structured using **Clean Architecture** and **MVVM**, ensuring scalability, maintainability, and testability.



### Layers Description

- **Presentation Layer**  
  Contains SwiftUI Views and corresponding ViewModels.  
  Responsible for displaying crypto data, managing UI state, and handling user interactions.

- **Domain Layer**  
  Contains **Use Cases**, **Entities**, and **Protocols**.  
  It defines the core business logic independent of the UI and data sources.

- **Data Layer**  
  Responsible for data retrieval and persistence.  
  Includes **NetworkService**, **Repositories**, and **CacheManager** for managing API data and caching.

---

## ⚙️ Features Implemented

1. **Top 5 Cryptocurrency Listing**  
   - Fetches real-time top 5 cryptocurrencies using CoinGecko API.  
   - Displays price, name, rank, and market capitalization.  

2. **Detailed Coin View**  
   - Displays 7-day market chart (prices array) fetched dynamically.  

3. **Clean Architecture + MVVM**  
   - Clear separation of concerns between presentation, domain, and data layers.  

4. **Network Layer**  
   - Uses `URLSession` with Swift’s `async/await` for asynchronous calls.  
   - Decodes JSON responses into model structures.  

5. **Cache Management**  
   - Custom `CacheManager` implemented using `FileManager`.  
   - Cache is valid for **24 hours** to improve performance and offline reliability.  

6. **Error Handling**  
   - Handles `URLError`, decoding errors, network timeouts, and cache expiry gracefully.  

7. **Unit Tests**  
   - Includes tests for **NetworkService** and  **CacheManager**.  

---

## 🧠 UI Components

| Component | Description |
|------------|-------------|
| **Image** | Displays crypto coin icon fetched from API |
| **Name** | Coin name (e.g., Bitcoin, Ethereum) |
| **Price** | Current price in AUD |
| **Market Cap Rank** | Rank of the cryptocurrency |
| **All-Time High (ATH)** | Highest historical value |
| **ATH Date** | Date when ATH was reached |
| **Chart View** | 7-day trendline for selected coin |

---

## 📲 Installation

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/yourusername/CryptoCurrencyAssessment.git

2️⃣ Open in Xcode
Open CryptoCurrencyAssessment.xcodeproj or .xcworkspace
Ensure iOS 16+ SDK and Xcode 15+
3️⃣ Run the App
Choose a Simulator (e.g., iPhone 15)
Press Cmd + R to run
