//
//  HomeView.swift
//  TapToAuth Demo
//
//  Created by Admin on 19/12/2024.
//

import SwiftUI

struct HomeView: View {
    private var user: User? {
        retrieveUser()
    }
    
    var body: some View {
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
                
                Spacer().frame(height: 30)
                
                // Greeting Text
                Text("Hello,")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(user?.userName ?? "Guest")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer().frame(height: 50)

                // Bank Card
                BankCardView(
                    bankName: "MineSec",
                    cardType: "Demo Card",
                    cardDescription: "5th Anniversary Special Card",
                    cardHolderName: user?.userName ?? "Guest",
                    cardNumberLastDigits: maskCardNumber(user?.cardNo),
                    backgroundColor: Color(UIColor.systemIndigo),
                    logo: Image("logo_minesec_white")
                )
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    logout()
                }) {
                    Text("Log out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
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
    
    private func maskCardNumber(_ cardNumber: String?) -> String {
        guard let cardNumber = cardNumber, cardNumber.count >= 4 else { return "••••" }
        return String(cardNumber.suffix(4))
    }
}

struct BankCardView: View {
    let bankName: String
    let cardType: String
    let cardDescription: String
    let cardHolderName: String
    let cardNumberLastDigits: String
    let backgroundColor: Color
    let logo: Image

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.indigo]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                // Bank Name and Card Type
                HStack {
                    logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                    Spacer()
                    Text(bankName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text("\(cardType) | \(cardDescription)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(cardHolderName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Masked Card Number
                HStack {
                    Spacer()
                    Text("•••• •••• •••• \(cardNumberLastDigits)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .tracking(2)
                }
            }
            .padding(20)
        }
        .frame(height: 200)
    }
}
