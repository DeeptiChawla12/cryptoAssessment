//
//  CryptoModel.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.

import Foundation

// MARK: - CryptoModel
// Represents a cryptocurrency’s market data fetched from the CoinGecko API.

struct CryptoModel: Codable ,Identifiable{
    // MARK: - Basic Information
    var id                           : String?
    var symbol                       : String?
    var name                         : String?
    var image                        : String?
    var current_price                 : Double?
    var market_cap                    : Double?
    var market_cap_rank                : Double?
    var fully_diluted_valuation        : Double?
    var total_volume                  : Double?
    var high_24h                      : Double?
    var low_24h                       : Double?
    var price_change_24h               : Double?
    var price_change_percentage_24h     : Double?
    var market_cap_change_24h           : Double?
    var market_cap_change_percentage_24h : Double?
    var circulating_supply            : Double?
    var total_supply                  : Double?
    var max_supply                    : Double?
    var ath                          : Double?
    var ath_change_percentage          : Double?
    var ath_date                      : String?
    var atl                          : Double?
    var atl_change_percentage          : Double?
    var atl_date                      : String?
    var roi                          : ROI?
    var last_updated                  : String?
}

// Represents ROI details of a crypto asset (if provided by API)
struct ROI: Codable {
    let times: Double?
    let currency: String?
    let percentage: Double?
}
