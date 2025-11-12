//
//  AccountValueCard.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import SwiftUI

/// `AccountValueCard` displays a styled card showing a user's cryptocurrency value information.

struct AccountValueCard: View {
    let crypto: CryptoModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // Displays a  "Account Value"
            Text(AppConstants.UI.accountValue)
                .foregroundColor(.gray)
                .font(.subheadline)
            
            // Shows the 24-hour price change and the coin symbol
            HStack(spacing: 2) {
                Text("\(crypto.price_change_24h ?? 0, specifier: "%.2f")")
                    .font(.headline)
                Text(crypto.symbol?.uppercased() ?? "")
                    .font(.headline)
            }
            
            Text("$\(crypto.price_change_percentage_24h ?? 0, specifier: "%.2f")")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}
