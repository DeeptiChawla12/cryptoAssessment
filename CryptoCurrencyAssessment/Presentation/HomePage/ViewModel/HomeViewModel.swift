//
//  HomeViewModel.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 10/11/25.
//

import Foundation
/// The `HomeViewModel` is responsible for managing and exposing cryptocurrency data
/// to the HomeView in an MVVM architecture.


class HomeViewModel : ObservableObject{
    /// Fetching the top five cryptocurrencies.
    private let fetchCryptoUseCase: FetchTopFiveCryptoUseCaseProtocol
    
    /// The list of top five cryptocurrencies fetched from the API or cache.
    @Published var fetchTopFivecryptos: [CryptoModel] = []
    
    /// A message describing any network or  error that occurs during data loading.
    @Published var errorMessage: String?
    
    /// Indicates whether a network request is currently in progress.
    @Published var isLoading = false
    
    /// The total value of the top five cryptocurrencies
    @Published var totalValue: Double = 0.0
    
    // MARK: - Initializer
    init(fetchCryptoUseCase: FetchTopFiveCryptoUseCaseProtocol) {
        self.fetchCryptoUseCase = fetchCryptoUseCase
    }
    
    
    /// Loads the top five cryptocurrencies asynchronously.
    
    @MainActor
    func loadTopFive() async {
            isLoading = true
            errorMessage = nil
            do {
                // Fetch the list of top five cryptos
                fetchTopFivecryptos = try await fetchCryptoUseCase.fetchTopFiveCryptoList()
                
               getAccountValue()
               
                
            } catch let error as NetworkError {
                // Handle known network errors gracefully
                errorMessage = error.localizedDescription  // User-friendly message
            } catch {
                // Handle unexpected errors
                errorMessage = "Unexpected error: \(error.localizedDescription)"
            }
            isLoading = false

    }
    
    func getAccountValue(){
        // Compute the total value of all fetched cryptos
        totalValue = fetchTopFivecryptos.reduce(0) { $0 + ($1.current_price ?? 0) }
    }
}
