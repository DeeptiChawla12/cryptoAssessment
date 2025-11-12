//
//  CryptoDetailViewModel.swift
//  CryptoCurrencyAssessment
//
//  Created by Deepti Chawla on 11/11/25.
//

import Foundation


/// CryptoDetailViewModel responsible for handling the business logic and state
/// of the cryptocurrency detail screen.



final class CryptoDetailViewModel: ObservableObject {
    // Stores the array of price data points for the selected cryptocurrency.
    @Published var prices: [Double] = []
    
    @Published var isLoading = false
    
    /// Stores the error message if the data fetch fails.
    @Published var errorMessage: String?
    
    
      /// Use case responsible for fetching market chart data.
    private let fetchChartUseCase: FetchChartUseCaseProtocol
    
    init(fetchChartUseCase: FetchChartUseCaseProtocol) {
        self.fetchChartUseCase = fetchChartUseCase
    }
    
    /// Fetches the market chart data for a given cryptocurrency ID.
    
    @MainActor
    func fetchChartData(for id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            // Call the use case to fetch the market chart data asynchronously.
            prices = try await fetchChartUseCase.execute(for: id)
        } catch {
            // Capture and display any error message.
            errorMessage = error.localizedDescription
        }
        // Reset loading state after operation completes.
        isLoading = false
    }
}


