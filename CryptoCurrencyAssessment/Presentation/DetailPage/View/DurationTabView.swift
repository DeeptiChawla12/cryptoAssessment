//
//  DurationTabView.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import SwiftUI



struct DurationTabView: View {
    let durations = ["1D", "1W", "1M", "1Y", "5Y", "All"]
    @State private var selected = "1D"
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(durations, id: \.self) { duration in
                Text(duration)
                    .font(.subheadline.bold())
                    .foregroundColor(selected == duration ? .white : .gray)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(selected == duration ? Color.orange : Color.clear)
                    .cornerRadius(10)
                    .onTapGesture { selected = duration }
            }
        }
        .padding(.vertical, 10)
    }
}
