//
//  AppConstants.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Foundation

// MARK: - AppConstants
/// Keeps the project clean, avoids hardcoding, and supports clean architecture.
enum AppConstants {
    
    // MARK: - API
    enum API {
        static let baseURL = "https://api.coingecko.com"
        static let apiKey = "CG-LXENXysWegGc4BWgoLfzWNL4"
        static let currency = "aud"
        static let topFiveCount = "5"
        
        // Common Paths
        static let cryptoMarketsPath = "/api/v3/coins/markets"
    }
    
    // MARK: - Query Parameter Keys
    enum QueryKeys {
        static let apiKey = "api_key"
        static let vsCurrency = "vs_currency"
        static let perPage = "per_page"
        static let page = "page"
        static let sparkline = "sparkline"
    }
    
    // MARK: - Cache Keys
    enum CacheKeys {
        static let topCryptos = "top_cryptos"
        static let cryptoImages = "crypto_images"
        static let cryptoAPICache = "CryptoAPICache"
        static let imageCache = "ImageCache"
    }
    
    // MARK: - Error Messages
    enum Errors {
        static let invalidResponse = "Invalid response from server."
        static let badURL = "Invalid server URL. Please try again later."
        static let decodingError = "Failed to process data. Please try again later."
        static let noInternet = "No internet connection. Please check your network."
        static let timeout = "The request timed out. Try again in a few moments."
        static let noData = "No data received from server."
        static let somethingWentWrong = "Something went wrong:"
        static let tryAgainLater = " Please try again later."
        static let serverErrorFormat = "Server error (code: %@)."
    }
    
    
    enum UI {
        // General
        static let loading = "Loading..."
        static let errorPrefix = "⚠️ "
        
        // Home View
        static let cryptoTitle = "Crypto"
        static let accountValueTitle = "Account Value"
        static let sendButtonTitle = "Send"
        static let receiveButtonTitle = "Receive"
        static let sendIcon = "arrow.up"
        static let receiveIcon = "arrow.down"
        static let accountValue = "Account Value"
        static let loadingChart = "Loading Chart..."
        static let noChartData  = "No chart data available"
        static let latestActivites =  "LATEST ACTIVITIES"
        static let  Received =    "Received"
        static let Sent = "Sent"
    }
    
    
    enum Images{
        static let arrowUp = "arrow.up"
        static let arrowDown = "arrow.down"
        static let arrowLeftarrowRight = "arrow.left.arrow.right"
        
    }
    
}
