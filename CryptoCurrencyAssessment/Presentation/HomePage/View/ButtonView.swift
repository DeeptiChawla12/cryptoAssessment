//
//  ButtonView.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import SwiftUI

/// A reusable and stylized button component used across the app.

struct ButtonView: View {
    /// The title text displayed on the button.
    let title: String
    
    /// The system image name (SF Symbol) to display alongside the title.
    let systemImage: String
    
    /// The action closure executed when the button is tapped.
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 28)
                .background(Color.black)
                .clipShape(Capsule())
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 3)
        }
        
    }
}
