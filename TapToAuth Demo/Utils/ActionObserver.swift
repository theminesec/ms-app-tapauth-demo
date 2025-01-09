//
//  ActionObserver.swift
//  TapToAuth Demo
//
//  Created by Admin on 09/01/2025.
//

import Foundation
import FirebaseDatabase

class ActionObserver {
    
    func observeCardActions(cardNumber: String, onPendingAction: @escaping (Order) -> Void) {
        let cardRef = Database.database().reference().child("actions").child(cardNumber)
        
        cardRef.observe(.value) { snapshot in            
            guard let orderData = snapshot.value as? [String: Any] else {
                print("No data found for card: \(cardNumber)")
                return
            }
            
            if let order = self.parseOrder(data: orderData) {
                print("Parsed Order: \(order)")
                    if order.status == .pending {
                    onPendingAction(order)
                }
            } else {
                print("Failed to parse Order from data: \(orderData)")
            }
            
        }
    }
    
    private func parseOrder(data: [String: Any]) -> Order? {
        guard
            let actionId = data["actionId"] as? String,
            let orderId = data["orderId"] as? String,
            let description = data["description"] as? String,
            let amount = data["amount"] as? String,
            let fullCardNo = data["fullCardNo"] as? String,
            let created = data["created"] as? Int,
            let expired = data["expired"] as? Int,
            let statusString = data["status"] as? String,
            let status = ActionStatus(rawValue: statusString.uppercased())
        else {
            print("Failed to parse Order data: \(data)")
            return nil
        }
        
        return Order(
            actionId: actionId,
            orderId: orderId,
            description: description,
            amount: amount,
            fullCardNo: fullCardNo,
            created: created,
            expired: expired,
            status: status
        )
    }
}
