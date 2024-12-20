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
                // Welcome Title
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(userName)!")
                    .font(.title)
                    .foregroundColor(.white)
                
                // Card UI
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.purple)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Card Header
                        HStack {
                            Text("BOC")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.white)
                        }
                        
                        // Card Description
                        Text("Credit Card | check description")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(userName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Card Number
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
            }
            .padding()
        }
    }
}
