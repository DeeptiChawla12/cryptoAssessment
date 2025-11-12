//
//  ImageCacheManager.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Cache
import UIKit

// MARK: - ImageCacheManager
/// A singleton class responsible for caching and retrieving images efficiently.
///
final class ImageCacheManager {
    
    /// The shared singleton instance for global image caching access.
    static let shared = ImageCacheManager()
    
    // MARK: - Private Properties
    /// The underlying cache storage handling disk and memory layers.
    private let storage: Storage<String, UIImage>
    
    /// The expiry duration for cached images (1 day).
    private let expiry: Expiry = .seconds(24 * 60 * 60) // 1 day
    
    // MARK: - Initialization
    private init() {
        // Disk configuration for persistent storage
        let diskConfig = DiskConfig(name: AppConstants.CacheKeys.imageCache, expiry: expiry)
        
        // Memory configuration for fast access
        let memoryConfig = MemoryConfig(expiry: expiry, countLimit: 100)
        
        storage = try! Storage<String, UIImage>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forImage()
        )
    }
    
    
    /// Retrieves an image from cache or downloads it if not available.
    func getImage(for url: URL) async throws -> UIImage {
        let key = url.absoluteString
        
        // Attempt to retrieve from cache
        if let cached = try? storage.object(forKey: key) {
            return cached
        }
        
        //  Download if not cached
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        //  Save to cache
        try? storage.setObject(image, forKey: key, expiry: expiry)
        return image
    }
}
