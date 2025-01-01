//
//  LoginView.swift
//  TapToAuth Demo
//
//  Created by Admin on 19/12/2024.
//
import SwiftUI

struct LoginView: View {
    @State private var name: String = ""
    @State private var testCardNo: String = ""
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
                    
                    TextField("", text: $testCardNo, prompt: Text("Enter card number").foregroundColor(.gray))
                        .padding()
                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 32)

                    Button(action: {
                        hideKeyboard()
                        isLoading = true
                        viewModel.startLoginProcess(userName: name, testCardNo: testCardNo)
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
            }
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                ContentView()
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
