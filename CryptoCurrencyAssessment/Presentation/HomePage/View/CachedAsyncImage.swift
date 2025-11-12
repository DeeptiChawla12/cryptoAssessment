//
//  CachedAsyncImage.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import SwiftUI

/// A SwiftUI view that asynchronously loads and displays an image from a given URL,
/// using a cache to improve performance and minimize redundant network requests.


struct CachedAsyncImage: View {
    let url: URL
    
    /// The loaded image (either from cache or downloaded).
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                // Display the loaded image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                // Show a progress indicator while the image is being fetched
                ProgressView()
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Asynchronously loads the image, first attempting to retrieve it from the cache.
    /// If it isn't cached, it downloads the image and stores it for future access.
    
    private func loadImage() async {
        do {
            image = try await ImageCacheManager.shared.getImage(for: url)
        } catch {
            print("❌ Failed to load cached image:", error)
        }
    }
}
