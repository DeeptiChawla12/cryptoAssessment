//
//  PriceHeaderView.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import SwiftUI


struct PriceHeaderView: View {
    let crypto: CryptoModel

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                // Name
                Text(crypto.name ?? "")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 16)
                
                // Price
                Text("$\(crypto.current_price ?? 0, specifier: "%.2f")")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // Change info
                if let change = crypto.price_change_percentage_24h,
                   let changeValue = crypto.price_change_24h {
                    HStack(spacing: 6) {
                        Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(change >= 0 ? .green : .red)
                        
                        Text("\(change >= 0 ? "+" : "")\(change, specifier: "%.2f")%")
                            .foregroundColor(change >= 0 ? .green : .red)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        
                        Text("\(change >= 0 ? "+" : "-")$\(abs(changeValue), specifier: "%.2f")")
                            .foregroundColor(change >= 0 ? .green : .red)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        
                        Text("Today")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
            }

            Spacer() // ✅ pushes image to the right

            CachedAsyncImage(url: URL(string: crypto.image ?? "" )!)
                .frame(width: 36, height: 36)
                .clipShape(Circle())
        }
        .frame(maxWidth: .infinity, alignment: .leading) // ✅ ensures text stays left-aligned
        .padding(.horizontal)
    }
}
