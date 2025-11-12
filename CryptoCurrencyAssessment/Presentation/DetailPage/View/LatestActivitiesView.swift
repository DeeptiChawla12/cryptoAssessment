//
//  LatestActivitiesView.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import SwiftUI

struct LatestActivitiesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppConstants.UI.latestActivites)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 4)
            
            ForEach(0..<3, id: \.self) { index in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(index == 2 ? AppConstants.UI.Received : AppConstants.UI.Sent)
                            .font(.headline)
                        Text("Jan \(4 - index), 2024")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 6, height: 6)
                            Text("0.0\(17 + index) BTC")
                                .bold()
                        }
                        Text("$\(700 + index * 200, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}
