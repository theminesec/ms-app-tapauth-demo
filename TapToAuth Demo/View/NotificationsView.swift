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
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    Text("Messages")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .padding(.top)

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
                                    }
                                }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    viewModel.fetchOrders(for: retrieveUser()?.cardNo ?? "")
                }
                .sheet(item: $selectedOrder) { order in
                    OrderDetailsDialog(order: order)
                }
                
                // Loading Indicator
                if viewModel.isLoading {
                    ZStack {
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
            
            Text("Created: \(order.formattedCreatedDate())")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Expires in: \(order.formattedExpiredDate())")
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .padding()
        .background(order.status.color)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

struct OrderDetailsDialog: View {
    let order: Order
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Order Details")
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
                    Text(order.orderId)
                        .font(.body)
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(order.description)
                        .font(.body)
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(order.amount)
                        .font(.body)
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Card No")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(order.fullCardNo)
                        .font(.body)
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Created Time")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(order.formattedCreatedDate())
                        .font(.body)
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expires In")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(order.formattedExpiredDate())
                        .font(.body)
                        .foregroundColor(.red)
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
