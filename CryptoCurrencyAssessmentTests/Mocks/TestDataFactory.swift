//
//  DataFactoryTest.swift
//  CryptoCurrencyAssessmentTests
//
//  Created by Deepti Chawla on 12/11/25.
//

import Foundation

@testable import CryptoCurrencyAssessment

/// Factory class for creating consistent test data across different test suites
/// Centralizes test data creation to ensure consistency and reduce duplication
enum DataFactoryTest {
    
    // MARK: - Crypto Models
    
    /// Creates a sample Bitcoin model for testing
    static func createBitcoin() -> CryptoModel {
        return CryptoModel(
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            current_price: 65000.0,
            market_cap: 1200000000000.0,
            market_cap_rank: 1.0,
            fully_diluted_valuation: 1300000000000.0,
            total_volume: 25000000000.0,
            high_24h: 66000.0,
            low_24h: 64000.0,
            price_change_24h: 1000.0,
            price_change_percentage_24h: 1.56,
            market_cap_change_24h: 20000000000.0,
            market_cap_change_percentage_24h: 1.69,
            circulating_supply: 19500000.0,
            total_supply: 21000000.0,
            max_supply: 21000000.0,
            ath: 69000.0,
            ath_change_percentage: -5.8,
            ath_date: "2021-11-10T14:24:11.849Z",
            atl: 67.81,
            atl_change_percentage: 95834.2,
            atl_date: "2013-07-06T00:00:00.000Z",
            roi: nil,
            last_updated: "2025-11-12T10:00:00.000Z"
        )
    }
    
    /// Creates a sample Ethereum model for testing
    static func createEthereum() -> CryptoModel {
        return CryptoModel(
            id: "ethereum",
            symbol: "eth",
            name: "Ethereum",
            image: "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
            current_price: 2400.0,
            market_cap: 290000000000.0,
            market_cap_rank: 2.0,
            fully_diluted_valuation: nil,
            total_volume: 12000000000.0,
            high_24h: 2450.0,
            low_24h: 2380.0,
            price_change_24h: -50.0,
            price_change_percentage_24h: -2.04,
            market_cap_change_24h: -6000000000.0,
            market_cap_change_percentage_24h: -2.03,
            circulating_supply: 120000000.0,
            total_supply: nil,
            max_supply: nil,
            ath: 4878.26,
            ath_change_percentage: -50.8,
            ath_date: "2021-11-10T14:24:19.604Z",
            atl: 0.432979,
            atl_change_percentage: 554000.0,
            atl_date: "2015-10-20T00:00:00.000Z",
            roi: DataFactoryTest.createROI(),
            last_updated: "2025-11-12T10:00:00.000Z"
        )
    }
    
    /// Creates a sample top-five cryptocurrency list
    static func createTopFiveCryptos() -> [CryptoModel] {
        return [
            createBitcoin(),
            createEthereum(),
            CryptoModel(
                id: "tether",
                symbol: "usdt",
                name: "Tether",
                image: "https://assets.coingecko.com/coins/images/325/large/Tether.png",
                current_price: 1.0,
                market_cap: 83000000000.0,
                market_cap_rank: 3.0,
                price_change_percentage_24h: 0.01
            ),
            CryptoModel(
                id: "binancecoin",
                symbol: "bnb",
                name: "BNB",
                image: "https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png",
                current_price: 310.0,
                market_cap: 47000000000.0,
                market_cap_rank: 4.0,
                price_change_percentage_24h: 2.15
            ),
            CryptoModel(
                id: "solana",
                symbol: "sol",
                name: "Solana",
                image: "https://assets.coingecko.com/coins/images/4128/large/solana.png",
                current_price: 58.0,
                market_cap: 26000000000.0,
                market_cap_rank: 5.0,
                price_change_percentage_24h: -3.42
            )
        ]
    }
    
    /// Creates a sample ROI object
    static func createROI() -> ROI {
        return ROI(
            times: 78.5,
            currency: "btc",
            percentage: 7850.123
        )
    }
    
    // MARK: - Chart Data
    
    /// Creates sample price data for chart testing
    static func createChartPrices() -> [Double] {
        return [
            65000.0, 65200.0, 64800.0, 65100.0, 65400.0,
            65300.0, 65600.0, 65800.0, 65500.0, 65700.0
        ]
    }
    
    /// Creates sample chart response for API testing
    static func createChartResponse() -> ChartResponse {
        let prices = [
            [1699833600000.0, 65000.0],
            [1699920000000.0, 65200.0],
            [1700006400000.0, 64800.0],
            [1700092800000.0, 65100.0],
            [1700179200000.0, 65400.0]
        ]
        return ChartResponse(prices: prices)
    }
    
    // MARK: - Error Objects
    
    /// Creates various network errors for testing error scenarios
    static func createNetworkErrors() -> [NetworkError] {
        return [
            .badURL,
            .invalidResponse(statusCode: 404),
            .decodingError,
            .noInternet,
            .timeout,
            .noData,
            .unknown(URLError(.cannotConnectToHost))
        ]
    }
}
