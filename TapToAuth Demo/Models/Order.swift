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

    // Format the created date
    func formattedCreatedDate() -> String {
        return formatTimestamp(created)
    }

    // Format the expiry date
    func formattedExpiredDate() -> String {
        return formatTimestamp(expired)
    }

    // Helper function to format a timestamp
    private func formatTimestamp(_ timestamp: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
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
        case .pending: return Color.yellow.opacity(0.3)
        case .confirmed: return Color.green.opacity(0.3)
        case .rejected: return Color.red.opacity(0.3)
        case .cancelled: return Color.gray.opacity(0.3)
        case .timeout: return Color.orange.opacity(0.3)
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
    let cardNo: String
}
