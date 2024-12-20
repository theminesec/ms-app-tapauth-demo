//
//  LoginView.swift
//  TapToAuth Demo
//
//  Created by Admin on 19/12/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var name: String = ""
    @State private var isLoggedIn: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Login")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 32)
                    
                    TextField("Enter your name", text: $name)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(.horizontal, 32)
                    
                    // Login Button
                    Button(action: {
                        if !name.isEmpty {
                            isLoggedIn = true
                        }
                    }) {
                        Text("Tap Card to Login")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                            .padding(.horizontal, 32)
                    }
                    .disabled(name.isEmpty)
                    
                    Spacer()
                }
                .padding(.top, 100)
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                HomeView(userName: name)
            }
        }
    }
}
