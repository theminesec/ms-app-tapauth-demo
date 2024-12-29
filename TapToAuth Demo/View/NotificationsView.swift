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
                VStack(alignment: .leading) {
                    // Title
                    Text("Messages")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .padding(.top)

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
                        }
                        .listStyle(PlainListStyle())
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
                            // Ensure selectedAmount is updated before showing TapCardView
                            selectedAmount = order.amount
                            DispatchQueue.main.async {
                                showTapCardView = true
                                selectedOrder = nil // Dismiss the sheet
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
                Text(order.amount)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: order.status.statusIcon)
                        .foregroundColor(order.status.color)
                    Text(order.status.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Text("Card: \(order.fullCardNo)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("Order: \(order.orderId)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            if order.status == .pending {
                Text("Expires in: \(order.formattedExpiredDate())")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else {
                Text("Created: \(order.formattedCreatedDate())")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(order.status.color)
        .cornerRadius(8)
        .shadow(radius: 2)
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
                detailRow(title: "Amount", content: order.amount)
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
        .cornerRadius(16)
        .shadow(radius: 8)
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
