//
//  HomeView.swift
//  TapToAuth Demo
//
//  Created by Admin on 19/12/2024.
//

import SwiftUI
struct HomeView: View {
    let userName: String

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(userName)!")
                    .font(.title)
                    .foregroundColor(.white)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.purple)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("BOC")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.white)
                        }
                        
                        Text("Credit Card | check description")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(userName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Text("•••• •••• •••• 5592")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                .frame(height: 200)
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    logout()
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
    
    
    private func logout() {
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.user)
        UIApplication.shared.resetRootView(to: LoginView())
    }
    
}
