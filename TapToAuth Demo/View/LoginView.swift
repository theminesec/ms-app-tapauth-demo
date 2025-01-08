//
//  LoginView.swift
//  TapToAuth Demo
//
//  Created by Admin on 19/12/2024.
//
import SwiftUI

struct LoginView: View {
    @State private var name: String = ""
    @State private var cardNumber: String = ""
    @State private var showCardAlert: Bool = false
    @StateObject private var viewModel = LoginViewModel()
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Image("logo_minesec_full")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .padding(.top, 32)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Login")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 32)
                    
                    TextField("", text: $name, prompt: Text("Enter your name").foregroundColor(.gray))
                        .padding()
                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .padding(.horizontal, 32)

                    Button(action: {
                        hideKeyboard()
                        if name == "test_user" {
                            showCardAlert = true
                        } else {
                            isLoading = true
                            viewModel.startLoginProcess(userName: name)
                        }
                    }) {
                        Text("Tap Card to Login")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                            .padding(.horizontal, 32)
                    }
                    .disabled(name.isEmpty || isLoading)
                    
                    if isLoading {
                        ProgressView()
                            .padding(.top)
                    }

                    Spacer()
                }
                .padding(.top, 50)
                .alert("Enter Card Number", isPresented: $showCardAlert) {
                    SecureField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    Button("Submit", action: submitCardNumber)
                    Button("Cancel", role: .cancel, action: { cardNumber = "" })
                } message: {
                    Text("Please enter your card number to proceed.")
                }
            }
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                ContentView()
            }
        }
    }
    
    private func submitCardNumber() {
        guard !cardNumber.isEmpty else {
            print("Card number is empty.")
            return
        }
        isLoading = true
        viewModel.performLogin(userName: name, cardUid: cardNumber, cardNo: cardNumber)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
