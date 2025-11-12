//
//  HomeView.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.
//

import SwiftUI
// HomeView represents the main screen of the crypto app.
// It displays the user's total account value, quick action buttons,
// and a list of the top cryptocurrencies fetched from the API.

struct HomeView: View {
    /// StateObject to manage and observe the ViewModel.
    @StateObject private var homeViewModel: HomeViewModel
    
    init() {
        let network = NetworkService()
        let repository = CryptoRepositoryImpl(networkService: network)
        let useCase = FetchCryptopFiveUseCases(cryptoRepository: repository)
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(fetchCryptoUseCase: useCase))
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Header Section
                Text(AppConstants.UI.cryptoTitle)
                    .font(.largeTitle.bold())
                // MARK: - Account Value Section
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppConstants.UI.accountValueTitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    // Displays total value with currency formatting
                    Text("$\(homeViewModel.totalValue, specifier: "%.2f")")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
                // MARK: - Action Buttons
                HStack(spacing: 16) {
                    ButtonView(title: AppConstants.UI.sendButtonTitle,
                               systemImage: AppConstants.UI.sendIcon) {
                        
                    }
                    
                    ButtonView(title: AppConstants.UI.receiveButtonTitle,
                               systemImage: AppConstants.UI.receiveIcon) {
                        
                    }
                }
                .padding(.vertical, 8)
                
                // MARK: - Data Section
                if homeViewModel.isLoading {
                    // Loading indicator while fetching data
                    ProgressView(AppConstants.UI.loading)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = homeViewModel.errorMessage {
                    // Error message display
                    Text(AppConstants.UI.errorPrefix + error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // List of top 5 cryptocurrencies
                    
                    
                    List(homeViewModel.fetchTopFivecryptos) { crypto in
                        NavigationLink(
                            destination: CryptoDetailView(
                                crypto: crypto, cryptoID: crypto.id ?? ""
                            )
                        ) {
                            CryptoRowView(crypto: crypto)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            // MARK: - Load Data Task
            // Automatically triggers API call when the view appears
            .task {
                await homeViewModel.loadTopFive()
            }
        }
        
    }
}



