//
//  CryptoRowView.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import SwiftUI

/// A reusable row view that displays summary information about a single cryptocurrency.

struct CryptoRowView: View {
    let crypto: CryptoModel
    
    var body: some View {
        HStack {
            // MARK: - Crypto Icon
            /// Loads and displays the crypto icon using a cached async image loader
            /// If the image fails to load, it defaults to a placeholder.
            CachedAsyncImage(url: URL(string: crypto.image ?? "" )!)
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            
            // MARK: - Crypto Name and Price
            VStack(alignment: .leading, spacing: 2) {
                Text(crypto.name ?? "")
                    .font(.headline)
                Text("$\(crypto.current_price ?? 0, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }
            
            Spacer()
            
            // MARK: - Price Change and Symbol
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing:2){
                    if let change = crypto.price_change_24h {
                        Text("\(change, specifier: "%.2f")")
                            .font(.headline)
                        
                    }
                    
                    Text(crypto.symbol?.uppercased() ?? "")
                        .font(.headline)
                }
                
                // Display 24-hour percentage change
                if let change = crypto.price_change_percentage_24h {
                    Text("$\(change, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                }
                
            }
        }
        .padding(.vertical, 6)
    }
}


