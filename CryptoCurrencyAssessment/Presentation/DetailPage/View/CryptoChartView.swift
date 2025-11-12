//
//  CryptoChartView.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//


import SwiftUI
import Charts

struct CryptoChartView: View {
    @ObservedObject var viewModel: CryptoDetailViewModel

    var body: some View {
        if viewModel.isLoading {
            ProgressView(AppConstants.UI.loadingChart)
                .frame(height: 220)
        } else if !viewModel.prices.isEmpty {
            let minPrice = viewModel.prices.min() ?? 0
            let maxPrice = viewModel.prices.max() ?? 0
            let padding = (maxPrice - minPrice) * 0.1

            Chart {
                ForEach(viewModel.prices.indices, id: \.self) { i in
                    LineMark(
                        x: .value("Index", i),
                        y: .value("Price", viewModel.prices[i])
                    )
                    .foregroundStyle(Color.orange)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineJoin: .round))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYScale(domain: (minPrice - padding)...(maxPrice + padding))
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 250)
            .padding(.horizontal, 10)
            
            //  Ensure there’s no background at all
            .background(Color.clear)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.clear)     // remove orange fill
                    .border(Color.clear, width: 0)
            }

        } else {
            Text(AppConstants.UI.noChartData)
                .foregroundColor(.gray)
                .frame(height: 250)
        }
    }
}
