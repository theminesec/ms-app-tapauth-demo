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
    @Published var selectedOrder: Order? = nil
    
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
            responseType: BaseResponse<Order>.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if response.code == 0 {
                        self?.updateOrderStatus(actionId: actionId, newStatus: .rejected)
                        completion(.success((response.body)))
                    } else {
                        completion(.failure(NSError(domain: "", code: response.code, userInfo: [NSLocalizedDescriptionKey: response.message])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func confirmOrder(actionId: String, cardNo: String, completion: @escaping (Result<Order, Error>) -> Void) {
        let confirmRequest = ConfirmRequest(cardData: ConfirmRequest.CardData(cardNo: cardNo))
        NetworkClient.shared.post(
            endpoint: .confirm(actionId: actionId),
            body: confirmRequest,
            responseType: BaseResponse<Order>.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if response.code == 0 {
                        self?.updateOrderStatus(actionId: actionId, newStatus: .confirmed)
                        completion(.success(response.body))
                    } else {
                        completion(.failure(NSError(domain: "", code: response.code, userInfo: [NSLocalizedDescriptionKey: response.message])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateOrderStatus(actionId: String, newStatus: ActionStatus) {
        if let index = orders.firstIndex(where: { $0.actionId == actionId }) {
            orders[index].status = newStatus
        }
    }
}
