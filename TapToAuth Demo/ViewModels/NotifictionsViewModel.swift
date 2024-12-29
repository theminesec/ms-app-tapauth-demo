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
    
    func rejectOrder(actionId: String, completion: @escaping (Result<Order, Error>) -> Void) {
        isLoading = true
        NetworkClient.shared.get(
            endpoint: .reject(actionId: actionId),
            responseType: BaseResponse<RejectResponseBody>.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if response.code == 0 {
                        if let index = self?.orders.firstIndex(where: { $0.actionId == actionId }) {
                            self?.orders[index].status = .rejected
                        }
                        completion(.success((response.body.action)))
                    } else {
                        completion(.failure(NSError(domain: "", code: response.code, userInfo: [NSLocalizedDescriptionKey: response.message])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
