//
//  Order.swift
//  TapToAuth Demo
//
//  Created by Admin on 28/12/2024.
//

import Foundation
import SwiftUICore

struct OrdersResponseBody: Codable {
    let list: [Order]
    let total: Int
}

struct Order: Codable, Identifiable {
    let actionId: String
    let orderId: String
    let description: String
    let amount: String
    let fullCardNo: String
    let created: Int
    let expired: Int
    var status: ActionStatus
    
    // Conform to Identifiable
    var id: String { actionId }

    func formattedCreatedDate() -> String {
        return created.getLocalFormattedTime()
    }

    func formattedExpiredDate(enablePrefix: Bool = false) -> String {
        return expired.formatTimeRemaining(enablePrefix: enablePrefix)
    }

}

enum ActionStatus: String, Codable {
    case pending = "PENDING"
    case confirmed = "CONFIRMED"
    case rejected = "REJECTED"
    case cancelled = "CANCELLED"
    case timeout = "TIMEOUT"

    var color: Color {
        switch self {
        case .pending: return Color.yellow
        case .confirmed: return Color.green
        case .rejected: return Color.red
        case .cancelled: return Color.gray
        case .timeout: return Color.orange
        }
    }

    var statusIcon: String {
        switch self {
        case .pending: return "info.circle"
        case .confirmed: return "checkmark.circle"
        case .rejected: return "xmark.circle"
        case .cancelled: return "slash.circle"
        case .timeout: return "clock"
        }
    }
}

typealias OrdersResponse = BaseResponse<OrdersResponseBody>

struct ConfirmRequest: Codable {
    let cardData: CardData

    struct CardData: Codable {
        let cardNo: String
    }
}
