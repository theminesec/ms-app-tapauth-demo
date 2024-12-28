//
//  NotifictionsViewModel.swift
//  TapToAuth Demo
//
//  Created by Admin on 28/12/2024.
//

import Foundation

class NotificationsViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchOrders(for cardNo: String) {
        isLoading = true
        errorMessage = nil
        
        NetworkClient.shared.get(
            endpoint: .orders(cardNo: cardNo),
            responseType: OrdersResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if response.code == 0 {
                        self?.orders = response.body.list
                    } else {
                        self?.errorMessage = response.message
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
