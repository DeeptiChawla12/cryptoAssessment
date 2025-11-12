//
//  NetworkError.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.
//

import Foundation

// MARK: - Network Error Enum
enum NetworkError: Error, LocalizedError {
    case badURL
    case invalidResponse(statusCode: Int)
    case decodingError
    case noInternet
    case timeout
    case noData
    case unknown(Error)

    var errorDescription: String? {
        // MARK: - Error Cases
        switch self {
        case .badURL:
            return AppConstants.Errors.badURL
        case .invalidResponse(let code):
            return String(format: AppConstants.Errors.serverErrorFormat, "\(code)") + AppConstants.Errors.tryAgainLater
        case .decodingError:
            return AppConstants.Errors.decodingError
        case .noInternet:
            return AppConstants.Errors.noInternet
        case .timeout:
            return AppConstants.Errors.timeout
        case .noData:
            return AppConstants.Errors.noData
        case .unknown(let error):
            return AppConstants.Errors.somethingWentWrong + "\(error.localizedDescription)"
        }
    }
}
