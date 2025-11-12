//
//  EndPoint.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.
//

import Foundation

// MARK: - Endpoint Protocol
// This protocol defines the structure of an API endpoint.

protocol EndPoint {
    /// The root URL for the API
    var baseURL: String { get }
    
    /// The specific path for the API resource
    var path: String { get }
    
    /// The HTTP method to be used (GET, POST, PUT, DELETE, etc.)
    var method: HTTPMethod { get }
    
    /// The query parameters to include in the request (optional)
    var queryItems: [URLQueryItem]? { get }
    
    /// The  final URL for the endpoint
    var url: URL? { get }
}

extension EndPoint {
    /// Constructs the full URL using baseURL, path, and queryItems.
    var url: URL? {
        var components = URLComponents(string: baseURL)
        components?.path = path
        components?.queryItems = queryItems
        return components?.url
    }
}
