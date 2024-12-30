//
//  NotificationsView.swift
//  TapToAuth Demo
//
//  Created by Admin on 23/12/2024.
//

import SwiftUI

struct NotificationsView: View {
    @State private var selectedOrder: Order? = nil
    @StateObject private var viewModel = NotificationsViewModel()
    @State private var showTapCardView = false
    @State private var selectedAmount: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading) {
                    // Centered Logo
                    HStack {
                        Spacer()
                        Image("logo_minesec_full")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                        Spacer()
                    }
                    .padding(.top)

                    Spacer().frame(height: 30)

                    // Title
                    Text("Messages")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)

                    // Content
                    if viewModel.orders.isEmpty && !viewModel.isLoading {
                        VStack {
                            Spacer()
                            Text("No notifications found!")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        List(viewModel.orders) { order in
                            OrderRow(order: order)
                                .onTapGesture {
                                    if order.status == .pending {
                                        selectedOrder = order
                                        viewModel.selectedOrder = order
                                    }
                                }
                                .listRowBackground(Color.white) // Set the background color for each row
                                .listRowSeparator(.hidden) // Hide the separator for each row
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden) // Hide the default background for the list
                    }
                }
                .onAppear {
                    viewModel.fetchOrders(for: retrieveUser()?.cardNo ?? "")
                }
                .sheet(item: $selectedOrder) { order in
                    OrderDetailsDialog(
                        order: order,
                        viewModel: viewModel,
                        selectedAmount: $selectedAmount,
                        showTapCardView: {
                            selectedAmount = order.amount
                            DispatchQueue.main.async {
                                showTapCardView = true
                                selectedOrder = nil
                            }
                        }
                    )
                }
                .fullScreenCover(isPresented: $showTapCardView) {
                    TapCardView(viewModel: viewModel)
                        .interactiveDismissDisabled(true)
                }

                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView("Loading Orders...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }
    }
}

struct OrderRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Amount with Dollar Sign
                Text("$\(order.amount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Spacer()

                // Status Icon and Status Text
                HStack(spacing: 4) {
                    Image(systemName: order.status.statusIcon)
                        .foregroundColor(order.status.color)
                    Text(order.status.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
            }

            HStack {
                // Show only the last 4 digits of the card number
                Text("Card: \(lastFourDigits(order.fullCardNo))")
                    .font(.subheadline)
                    .foregroundColor(.black)

                Spacer()

                // Order ID
                Text("Order: \(order.orderId)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            if order.status == .pending {
                // Expiry Date
                Text("Expires in: \(order.formattedExpiredDate())")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else {
                // Created Date
                Text("Created: \(order.formattedCreatedDate())")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(order.status.color.opacity(0.2))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private func lastFourDigits(_ cardNumber: String) -> String {
        guard cardNumber.count >= 4 else { return "" }
        return String(cardNumber.suffix(4))
    }
}

struct OrderDetailsDialog: View {
    let order: Order
    @ObservedObject var viewModel: NotificationsViewModel
    @Environment(\.presentationMode) var presentationMode
    var selectedAmount: Binding<String>
    var showTapCardView: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Order Details")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)

            VStack(alignment: .leading, spacing: 16) {
                detailRow(title: "Order ID", content: order.orderId)
                detailRow(title: "Description", content: order.description)
                detailRow(title: "Amount", content: "$\(order.amount)")
                detailRow(title: "Card No", content: order.fullCardNo)
                if order.status == .pending {
                    detailRow(title: "Expires In", content: order.formattedExpiredDate(), contentColor: .red)
                } else {
                    detailRow(title: "Created Time", content: order.formattedCreatedDate())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: 10) {
                Button(action: {
                    selectedAmount.wrappedValue = order.amount
                    showTapCardView()
                }) {
                    Text("Tap")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                }

                Button(action: {
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
                    viewModel.rejectOrder(actionId: order.actionId) { result in
                        switch result {
                        case .success:
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            print("Failed to reject order: \(error.localizedDescription)")
                        }
                    }
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
        .padding()
    }

    private func detailRow(title: String, content: String, contentColor: Color = .black) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            Text(content)
                .font(.body)
                .foregroundColor(contentColor)
        }
    }
}
