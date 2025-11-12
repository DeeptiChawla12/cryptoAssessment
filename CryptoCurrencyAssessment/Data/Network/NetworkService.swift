//
//  NetworkService.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.
//

import Foundation

// MARK: - Protocol Definition
/// Defines a contract for making network requests.
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: EndPoint, type: T.Type) async throws -> T
}

// MARK: - Network Service Implementation

final class NetworkService: NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: EndPoint, type: T.Type) async throws -> T {
        // Validate endpoint URL
        guard let url = endpoint.url else {
            throw NetworkError.badURL
        }
        
        // Create URLRequest with HTTP method and timeout
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 15 // seconds
        
        do {
            // Perform network call using async/await URLSession API
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Validate response as HTTPURLResponse
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse(statusCode: -1)
            }
            
            // Check status code
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                // Decode JSON data into expected Decodable model
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
            
        } catch let urlError as URLError {
            // Handle specific URLSession errors
            switch urlError.code {
            case .notConnectedToInternet:
                throw NetworkError.noInternet
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(urlError)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
