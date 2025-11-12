//
//  ActionButtonsView.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import SwiftUI


struct ActionButtonsView: View {
    private let icons = [AppConstants.Images.arrowUp,AppConstants.Images.arrowDown, AppConstants.Images.arrowLeftarrowRight]
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(icons, id: \.self) { icon in
                Button(action: {
                    // Handle action here
                }) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .padding(8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial) // adds a frosted-glass blur effect
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .padding()
    }
}

#Preview {
    ActionButtonsView()
}
