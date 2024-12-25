//
//  NotificationsView.swift
//  TapToAuth Demo
//
//  Created by Admin on 23/12/2024.
//

import SwiftUI

struct NotificationsView: View {
    @State private var showDialog = false
    @State private var selectedNotification = notifications[0]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Messages")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .padding(.top)

                List(notifications) { notification in
                    NotificationRow(notification: notification)
                        .onTapGesture {
                            if notification.status == .pending {
                                selectedNotification = notification
                                showDialog = true
                            }
                        }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showDialog) {
                NotificationDetailsDialog(notification: selectedNotification)
            }
        }
    }
}

struct NotificationRow: View {
    let notification: Notification

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(notification.amount)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: notification.status.statusIcon)
                        .foregroundColor(notification.status == .pending ? .yellow : .gray)
                    Text(notification.status.statusText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Text("Card: \(notification.card)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("Order: \(notification.order)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            if let expiresIn = notification.expiresIn {
                Text("Expires in: \(expiresIn)")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else {
                Text("Created: \(notification.createdTime)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(notification.status.color)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

struct NotificationDetailsDialog: View {
    let notification: Notification
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Message Details")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order ID")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(notification.order)
                        .font(.body)
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text("Pay \(notification.amount) to the TV")
                        .font(.body)
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(notification.amount)
                        .font(.body)
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Card No")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(notification.card)
                        .font(.body)
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Created Time")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(notification.createdTime)
                        .font(.body)
                        .foregroundColor(.black)
                }

                if let expiresIn = notification.expiresIn {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Expires In")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text(expiresIn)
                            .font(.body)
                            .foregroundColor(.red)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: 10) {
                Button(action: {
                    print("Tapped")
                }) {
                    Text("Tap")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                }

                Button(action: {
                    print("Do it later")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Do It Later")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.yellow)
                        .cornerRadius(8)
                }

                Button(action: {
                    print("Rejected")
                }) {
                    Text("Reject")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
        .padding()
    }
}

struct Notification: Identifiable {
    let id = UUID()
    let amount: String
    let card: String
    let order: String
    let createdTime: String
    let expiresIn: String?
    let status: NotificationStatus
}

enum NotificationStatus {
    case pending
    case confirmed
    case timeout

    var color: Color {
        switch self {
        case .pending: return Color.yellow.opacity(0.3)
        case .confirmed: return Color.green.opacity(0.3)
        case .timeout: return Color.gray.opacity(0.3)
        }
    }

    var statusText: String {
        switch self {
        case .pending: return "PENDING"
        case .confirmed: return "CONFIRMED"
        case .timeout: return "TIME-OUT"
        }
    }

    var statusIcon: String {
        switch self {
        case .pending: return "info.circle"
        case .confirmed: return "checkmark.circle"
        case .timeout: return "xmark.circle"
        }
    }
}

let notifications = [
    Notification(amount: "$493.64", card: "5526", order: "0022149855633253", createdTime: "2024-12-23 17:24:56", expiresIn: "9m 56s", status: .pending),
    Notification(amount: "$128.35", card: "3658", order: "9855856233523256", createdTime: "2024-12-23 17:24:56", expiresIn: nil, status: .confirmed),
    Notification(amount: "$328.05", card: "3648", order: "1644856233521652", createdTime: "2024-12-23 17:24:56", expiresIn: nil, status: .timeout)
]
