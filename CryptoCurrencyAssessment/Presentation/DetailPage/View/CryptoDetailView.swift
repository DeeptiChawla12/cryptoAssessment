//
//  CryptoDetailView.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import SwiftUI
import Charts //  Use Swift Charts for graph



struct CryptoDetailView: View {
    let crypto: CryptoModel
    @StateObject private var viewModel: CryptoDetailViewModel
    let cryptoID: String
    
    init(crypto: CryptoModel, cryptoID: String) {
        self.crypto = crypto
        self.cryptoID = cryptoID
        let network = NetworkService()
        let repository = DetailCryptoRepositoryImpl(networkService: network)
        let useCase = FetchChartUseCase(detailrepository: repository)
        _viewModel = StateObject(wrappedValue: CryptoDetailViewModel(fetchChartUseCase: useCase))
    }
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    PriceHeaderView(crypto: crypto)
                    CryptoChartView(viewModel: viewModel)
                    DurationTabView()
                    AccountValueCard(crypto: crypto)
                    LatestActivitiesView()
                        .padding(.bottom, 100) // leave space for floating buttons
                }
                .padding(.horizontal)
            }
            
            // Floating Action Buttons
            ActionButtonsView()
                .padding(.bottom, 20)
        }
        .task {
            if let id = crypto.id {
                await viewModel.fetchChartData(for: id)
            }
        }
//        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
      
    }
}
