//
//  CryptoEndPoint.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.
//

import Foundation


// MARK: - CryptoEndPoint
/// Defines all API endpoints related to cryptocurrency data.
enum CryptoEndPoint: EndPoint {
    
    /// Fetches the top five cryptocurrencies based on market data.
    case topFive
    
    /// Fetches market chart data for a specific coin (e.g., Bitcoin) over a number of days.
    case marketChart(id: String, days: Int)
    
    /// The base URL for all CoinGecko API requests.
    var baseURL: String {
        AppConstants.API.baseURL
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .topFive:
            return AppConstants.API.cryptoMarketsPath
        case .marketChart(let id, _):
            return "/api/v3/coins/\(id)/market_chart"
        }
    }
    
    // MARK: - Query Parameters
    var queryItems: [URLQueryItem]? {
        switch self {
        case .topFive:
            return [
                URLQueryItem(name: AppConstants.QueryKeys.apiKey, value: AppConstants.API.apiKey),
                URLQueryItem(name: AppConstants.QueryKeys.vsCurrency, value: AppConstants.API.currency),
                URLQueryItem(name: AppConstants.QueryKeys.perPage, value: AppConstants.API.topFiveCount)
            ]
            
        case .marketChart(_, let days):
            return [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "days", value: "\(days)")
            ]
        }
    }
    
    var method: HTTPMethod { .get }
}
